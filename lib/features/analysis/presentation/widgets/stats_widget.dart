import 'package:flutter/material.dart';

Widget buildStatTile(BuildContext context, String title, int value, IconData icon, Color color) {
  return Column(
    children: [
      Icon(icon, color: color, size: 28),
      SizedBox(height: 4),
      Text('$value', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
      Text(title, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall!.color)),
    ],
  );
}
