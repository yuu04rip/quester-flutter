// lib/widgets/ic_avatar_default.dart

import 'package:flutter/material.dart';

/// Icona avatar default (equivalente a ic_avatar_default.xml)
class IcAvatarDefault extends StatelessWidget {
  final double size;
  final Color color;

  const IcAvatarDefault({
    super.key,
    this.size = 24,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.person,
      size: size,
      color: color,
    );
  }
}