import 'package:flutter/material.dart';

class WeatherItem extends StatelessWidget {
  final int value;
  final String unit;
  final String imageUrl;

  const WeatherItem({
    Key? key,
    required this.value,
    required this.unit,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          height: 55,
          width: 55,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Image.asset(imageUrl),
        ),
        // const SizedBox(
        //   height: 2.0,
        // ),
        Text(
          value.toString() + unit,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
