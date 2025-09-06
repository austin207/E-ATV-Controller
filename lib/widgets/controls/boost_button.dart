import 'package:flutter/material.dart';

class BoostButton extends StatelessWidget {
  final double capacitorCharge;
  final bool canBoost;
  final bool isActive;
  final Function(bool isActive) onBoostChanged;

  const BoostButton({
    Key? key,
    required this.capacitorCharge,
    required this.canBoost,
    required this.isActive,
    required this.onBoostChanged,
  }) : super(key: key);

  void _hapticFeedback() async {
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: canBoost ? (_) {
        _hapticFeedback();
        onBoostChanged(true);
      } : null,
      onTapUp: (_) {
        onBoostChanged(false);
      },
      onTapCancel: () {
        onBoostChanged(false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: isActive
                ? [Colors.red[400]!, Colors.yellow[600]!]
                : canBoost
                ? [Colors.orange[600]!, Colors.red[700]!]
                : [Colors.grey[600]!, Colors.grey[800]!],
          ),
          boxShadow: isActive ? [
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.7),
              spreadRadius: 4,
              blurRadius: 12,
            )
          ] : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              spreadRadius: 2,
              blurRadius: 6,
            )
          ],
        ),
        child: Stack(
          children: [
            // Capacitor charge ring
            Center(
              child: SizedBox(
                width: 110,
                height: 110,
                child: CircularProgressIndicator(
                  value: capacitorCharge / 100.0,
                  strokeWidth: 4,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    capacitorCharge > 20 ? Colors.white : Colors.red,
                  ),
                ),
              ),
            ),
            // Button content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'BOOST',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${capacitorCharge.toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  if (!canBoost)
                    const Text(
                      'CHARGING',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
