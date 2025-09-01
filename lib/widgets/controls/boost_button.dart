import 'package:flutter/material.dart';

class BoostButton extends StatefulWidget {
  final Function(bool isBoosting) onBoostChanged;
  final double capacitorCharge;

  BoostButton({
    required this.onBoostChanged,
    required this.capacitorCharge,
  });

  @override
  _BoostButtonState createState() => _BoostButtonState();
}

class _BoostButtonState extends State<BoostButton> {
  bool isBoosting = false;

  @override
  Widget build(BuildContext context) {
    bool canBoost = widget.capacitorCharge > 20.0;

    return GestureDetector(
      onTapDown: canBoost ? (_) {
        setState(() {
          isBoosting = true;
        });
        widget.onBoostChanged(true);
      } : null,
      onTapUp: (_) {
        setState(() {
          isBoosting = false;
        });
        widget.onBoostChanged(false);
      },
      onTapCancel: () {
        setState(() {
          isBoosting = false;
        });
        widget.onBoostChanged(false);
      },
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: isBoosting
                ? [Colors.red, Colors.yellow]
                : canBoost
                ? [Colors.orange, Colors.red[800]!]
                : [Colors.grey, Colors.grey[800]!],
          ),
          boxShadow: isBoosting ? [
            BoxShadow(
              color: Colors.red.withOpacity(0.7),
              spreadRadius: 4,
              blurRadius: 12,
            )
          ] : null,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'BOOST',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${widget.capacitorCharge.toInt()}%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
