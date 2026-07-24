import 'package:flutter/material.dart';
import '../../../models/game_object.dart';
import '../fruit_duel_controller.dart';
import 'explosion_effect.dart';
import 'fruit_visuals.dart';
import 'sliced_fruit_effect.dart';

/// Displays whatever is happening in the center of the arena: the live,
/// gently bouncing fruit/bomb; or — once it's been cut — the appropriate
/// one-shot effect (halves + juice for a fruit, flash + shrapnel + smoke
/// for a bomb). Only one object is ever live at a time, matching the
/// game's spawn rules; this widget only reacts to state, it doesn't own
/// any game logic itself.
class ArenaObjectView extends StatefulWidget {
  final FruitDuelController controller;
  const ArenaObjectView({super.key, required this.controller});

  @override
  State<ArenaObjectView> createState() => _ArenaObjectViewState();
}

class _ArenaObjectViewState extends State<ArenaObjectView> {
  int _lastSeenResultTick = 0;

  // The most recently resolved object, shown transiently while its
  // slice/explosion effect plays out.
  GameObject? _resolvedObject;
  Key _effectKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _lastSeenResultTick = widget.controller.resultTick;
  }

  @override
  void didUpdateWidget(covariant ArenaObjectView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkForNewResult();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkForNewResult();
  }

  void _checkForNewResult() {
    final c = widget.controller;
    if (c.resultTick == _lastSeenResultTick) return;
    _lastSeenResultTick = c.resultTick;

    final obj = c.lastResolvedObject;
    if (obj == null) return;

    setState(() {
      _resolvedObject = obj;
      _effectKey = UniqueKey();
    });

    final effectDuration = obj.kind == ObjectKind.bomb
        ? const Duration(milliseconds: 650)
        : const Duration(milliseconds: 550);
    Future.delayed(effectDuration, () {
      if (mounted && _resolvedObject?.id == obj.id) {
        setState(() => _resolvedObject = null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Re-check on every rebuild too (e.g. triggered by the parent's
    // ChangeNotifier listener) in case didUpdateWidget didn't fire.
    _checkForNewResult();

    final obj = widget.controller.currentObject;

    return SizedBox(
      width: 170,
      height: 170,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          if (_resolvedObject != null)
            _resolvedObject!.kind == ObjectKind.bomb
                ? ExplosionEffect(key: _effectKey)
                : SlicedFruitEffect(key: _effectKey, emoji: _resolvedObject!.emoji),
          if (obj != null)
            _LiveObject(key: ValueKey(obj.id), object: obj),
        ],
      ),
    );
  }
}

/// The still-uncut object: pops in, then floats/bounces gently in place
/// until it's cut or times out.
class _LiveObject extends StatefulWidget {
  final GameObject object;
  const _LiveObject({super.key, required this.object});

  @override
  State<_LiveObject> createState() => _LiveObjectState();
}

class _LiveObjectState extends State<_LiveObject>
    with TickerProviderStateMixin {
  late final AnimationController _appear;
  late final AnimationController _bounce;

  @override
  void initState() {
    super.initState();
    _appear = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )..forward();
    _bounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _appear.dispose();
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBomb = widget.object.kind == ObjectKind.bomb;
    return AnimatedBuilder(
      animation: Listenable.merge([_appear, _bounce]),
      builder: (context, child) {
        final pop = Curves.elasticOut.transform(_appear.value);
        final floatY = Curves.easeInOut.transform(_bounce.value) * 10 - 5;
        return Transform.translate(
          offset: Offset(0, floatY),
          child: Transform.scale(scale: pop, child: child),
        );
      },
      child: CustomPaint(
        size: const Size(112, 112),
        painter: isBomb
            ? const BombPainter()
            : FruitPainter(emoji: widget.object.emoji),
      ),
    );
  }
}
