import 'package:flutter/material.dart';

/// A button that plays a short bounce + icon-swap animation when pressed,
/// giving visible feedback that the product was added to the cart.
class AddToCartButton extends StatefulWidget {
  const AddToCartButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<AddToCartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );
  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 1),
    TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 1),
  ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  bool _justAdded = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    widget.onPressed();
    setState(() => _justAdded = true);
    await _controller.forward(from: 0);
    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _justAdded = false);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: FilledButton.icon(
        onPressed: _handleTap,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: Icon(
            _justAdded ? Icons.check_circle : Icons.add_shopping_cart,
            key: ValueKey(_justAdded),
          ),
        ),
        label: Text(_justAdded ? 'Ajouté !' : 'Ajouter au panier'),
      ),
    );
  }
}
