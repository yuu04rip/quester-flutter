import 'dart:math';
import 'package:flutter/material.dart';

/// Minigioco arcade fullscreen:
/// - navicella con movimento fluido
/// - alieni mobili
/// - laser con scie
/// - esplosioni particellari
/// - stelle animate
/// - difficoltà progressiva
/// - respawn degli alieni
class ArcadeMiniGameWidget extends StatefulWidget {
  const ArcadeMiniGameWidget({super.key});

  @override
  State<ArcadeMiniGameWidget> createState() => _ArcadeMiniGameWidgetState();
}

class _ArcadeMiniGameWidgetState extends State<ArcadeMiniGameWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  final Random _random = Random();

  final List<_Laser> _lasers = [];
  final List<_Alien> _invaders = [];
  final List<_ExplosionParticle> _particles = [];
  final List<_Star> _stars = [];

  double _shipX = 0.5;
  double _shipY = 0.82;

  double _targetX = 0.5;
  double _targetY = 0.5;

  double _moveTimer = 0;
  double _shootTimer = 0;
  double _spawnTimer = 0;

  double _difficulty = 1.0;

  @override
  void initState() {
    super.initState();

    _createStars();
    _initAliens();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )
      ..addListener(_updateGameLoop)
      ..repeat();
  }

  void _createStars() {
    _stars.clear();

    for (int i = 0; i < 70; i++) {
      _stars.add(
        _Star(
          pos: Offset(
            _random.nextDouble(),
            _random.nextDouble(),
          ),
          speed: 0.0005 + _random.nextDouble() * 0.002,
          size: 0.5 + _random.nextDouble() * 1.8,
          opacity: 0.2 + _random.nextDouble() * 0.8,
        ),
      );
    }
  }

  void _initAliens() {
    _invaders.clear();

    final count = 8 + (_difficulty ~/ 2);

    for (int i = 0; i < count; i++) {
      _invaders.add(
        _Alien(
          pos: Offset(
            0.08 + _random.nextDouble() * 0.84,
            0.08 + _random.nextDouble() * 0.70,
          ),
          velocity: Offset(
            (_random.nextDouble() - 0.5) * 0.002,
            (_random.nextDouble() - 0.5) * 0.0015,
          ),
          phase: _random.nextDouble() * pi * 2,
          alive: true,
        ),
      );
    }
  }

  void _updateGameLoop() {
    if (!mounted) return;

    setState(() {
      _updateStars();
      _updateShip();
      _updateAliens();
      _updateShooting();
      _updateLasers();
      _updateParticles();

      _spawnTimer += 0.016;

      if (_spawnTimer > 8.0 && _invaders.where((a) => a.alive).length < 5) {
        _spawnTimer = 0;
        _spawnAlien();
      }

      if (_invaders.every((alien) => !alien.alive)) {
        _difficulty += 0.25;
        _initAliens();
      }
    });
  }

  void _updateStars() {
    for (final star in _stars) {
      star.pos = Offset(
        star.pos.dx,
        star.pos.dy + star.speed * _difficulty,
      );

      if (star.pos.dy > 1.0) {
        star.pos = Offset(
          _random.nextDouble(),
          0,
        );
      }
    }
  }

  void _updateShip() {
    _moveTimer += 0.016;

    if (_moveTimer > 2.0 + _random.nextDouble() * 2.0) {
      _moveTimer = 0;

      _targetX = 0.12 + _random.nextDouble() * 0.76;
      _targetY = 0.35 + _random.nextDouble() * 0.50;
    }

    final smoothing = 0.025 + (_difficulty * 0.002);

    _shipX += (_targetX - _shipX) * smoothing;
    _shipY += (_targetY - _shipY) * smoothing;

    _shipX = _shipX.clamp(0.06, 0.94);
    _shipY = _shipY.clamp(0.12, 0.94);
  }

  void _updateAliens() {
    for (final alien in _invaders) {
      if (!alien.alive) continue;

      alien.phase += 0.02;

      final waveX = sin(alien.phase) * 0.0008;
      final waveY = cos(alien.phase * 0.7) * 0.0005;

      alien.pos = Offset(
        alien.pos.dx + alien.velocity.dx + waveX,
        alien.pos.dy + alien.velocity.dy + waveY,
      );

      if (alien.pos.dx < 0.05 || alien.pos.dx > 0.95) {
        alien.velocity = Offset(
          -alien.velocity.dx,
          alien.velocity.dy,
        );
      }

      if (alien.pos.dy < 0.05 || alien.pos.dy > 0.82) {
        alien.velocity = Offset(
          alien.velocity.dx,
          -alien.velocity.dy,
        );
      }
    }
  }

  void _updateShooting() {
    _shootTimer += 0.016;

    final fireRate = max(
      0.12,
      0.28 - (_difficulty * 0.015),
    );

    if (_shootTimer < fireRate) return;

    _shootTimer = 0;

    final aliveAliens = _invaders.where((a) => a.alive).toList();

    if (aliveAliens.isEmpty) return;

    // Bersaglio più vicino alla navicella.
    aliveAliens.sort((a, b) {
      final da = _distanceSquared(a.pos, Offset(_shipX, _shipY));
      final db = _distanceSquared(b.pos, Offset(_shipX, _shipY));

      return da.compareTo(db);
    });

    final target = aliveAliens.first;

    final dx = target.pos.dx - _shipX;
    final dy = target.pos.dy - _shipY;

    final length = sqrt(dx * dx + dy * dy);

    if (length <= 0) return;

    const laserSpeed = 0.018;

    _lasers.add(
      _Laser(
        pos: Offset(_shipX, _shipY),
        velocity: Offset(
          dx / length * laserSpeed,
          dy / length * laserSpeed,
        ),
        life: 1.0,
      ),
    );
  }

  void _updateLasers() {
    for (int i = _lasers.length - 1; i >= 0; i--) {
      final laser = _lasers[i];

      laser.previousPos = laser.pos;

      laser.pos = Offset(
        laser.pos.dx + laser.velocity.dx,
        laser.pos.dy + laser.velocity.dy,
      );

      laser.life -= 0.012;

      if (
      laser.pos.dx < -0.1 ||
          laser.pos.dx > 1.1 ||
          laser.pos.dy < -0.1 ||
          laser.pos.dy > 1.1 ||
          laser.life <= 0
      ) {
        _lasers.removeAt(i);
        continue;
      }

      bool hit = false;

      for (final alien in _invaders) {
        if (!alien.alive) continue;

        final distance = sqrt(
          _distanceSquared(laser.pos, alien.pos),
        );

        if (distance < 0.045) {
          alien.alive = false;
          hit = true;
          _createExplosion(alien.pos);
          break;
        }
      }

      if (hit) {
        _lasers.removeAt(i);
      }
    }
  }

  void _updateParticles() {
    for (int i = _particles.length - 1; i >= 0; i--) {
      final particle = _particles[i];

      particle.pos = Offset(
        particle.pos.dx + particle.velocity.dx,
        particle.pos.dy + particle.velocity.dy,
      );

      particle.velocity = Offset(
        particle.velocity.dx * 0.98,
        particle.velocity.dy * 0.98 + 0.00015,
      );

      particle.life -= 0.025;

      if (particle.life <= 0) {
        _particles.removeAt(i);
      }
    }
  }

  void _createExplosion(Offset position) {
    for (int i = 0; i < 16; i++) {
      final angle = _random.nextDouble() * pi * 2;
      final speed = 0.002 + _random.nextDouble() * 0.006;

      _particles.add(
        _ExplosionParticle(
          pos: position,
          velocity: Offset(
            cos(angle) * speed,
            sin(angle) * speed,
          ),
          life: 0.8 + _random.nextDouble() * 0.5,
          size: 1.5 + _random.nextDouble() * 3,
        ),
      );
    }
  }

  void _spawnAlien() {
    _invaders.add(
      _Alien(
        pos: Offset(
          _random.nextDouble(),
          0.1 + _random.nextDouble() * 0.6,
        ),
        velocity: Offset(
          (_random.nextDouble() - 0.5) * 0.002,
          (_random.nextDouble() - 0.5) * 0.001,
        ),
        phase: _random.nextDouble() * pi * 2,
        alive: true,
      ),
    );
  }

  double _distanceSquared(Offset a, Offset b) {
    final dx = a.dx - b.dx;
    final dy = a.dy - b.dy;

    return dx * dx + dy * dy;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return CustomPaint(
            size: Size(
              constraints.maxWidth,
              constraints.maxHeight,
            ),
            painter: _ArcadePainter(
              shipPosition: Offset(_shipX, _shipY),
              targetPosition: Offset(_targetX, _targetY),
              aliens: _invaders,
              lasers: _lasers,
              particles: _particles,
              stars: _stars,
              primaryColor: theme.colorScheme.primary,
              secondaryColor: theme.colorScheme.secondary,
            ),
          );
        },
      ),
    );
  }
}

class _ArcadePainter extends CustomPainter {
  final Offset shipPosition;
  final Offset targetPosition;

  final List<_Alien> aliens;
  final List<_Laser> lasers;
  final List<_ExplosionParticle> particles;
  final List<_Star> stars;

  final Color primaryColor;
  final Color secondaryColor;

  _ArcadePainter({
    required this.shipPosition,
    required this.targetPosition,
    required this.aliens,
    required this.lasers,
    required this.particles,
    required this.stars,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawStars(canvas, size);
    _drawAliens(canvas, size);
    _drawLasers(canvas, size);
    _drawParticles(canvas, size);
    _drawShip(canvas, size);
  }

  Offset _screen(Offset normalized, Size size) {
    return Offset(
      normalized.dx * size.width,
      normalized.dy * size.height,
    );
  }

  void _drawStars(Canvas canvas, Size size) {
    for (final star in stars) {
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: star.opacity);

      canvas.drawCircle(
        _screen(star.pos, size),
        star.size,
        paint,
      );
    }
  }

  void _drawAliens(Canvas canvas, Size size) {
    for (final alien in aliens) {
      if (!alien.alive) continue;

      final position = _screen(alien.pos, size);

      final paint = Paint()
        ..color = secondaryColor.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;

      final path = Path()
        ..moveTo(position.dx, position.dy - 8)
        ..lineTo(position.dx + 8, position.dy - 3)
        ..lineTo(position.dx + 6, position.dy + 7)
        ..lineTo(position.dx, position.dy + 4)
        ..lineTo(position.dx - 6, position.dy + 7)
        ..lineTo(position.dx - 8, position.dy - 3)
        ..close();

      canvas.drawPath(path, paint);

      canvas.drawCircle(
        Offset(position.dx - 3, position.dy - 1),
        1.2,
        Paint()..color = secondaryColor,
      );

      canvas.drawCircle(
        Offset(position.dx + 3, position.dy - 1),
        1.2,
        Paint()..color = secondaryColor,
      );
    }
  }

  void _drawLasers(Canvas canvas, Size size) {
    for (final laser in lasers) {
      final start = _screen(laser.previousPos, size);
      final end = _screen(laser.pos, size);

      final paint = Paint()
        ..color = primaryColor.withValues(alpha: laser.life)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(start, end, paint);

      canvas.drawCircle(
        end,
        3,
        Paint()
          ..color = primaryColor.withValues(alpha: laser.life)
          ..maskFilter = const MaskFilter.blur(
            BlurStyle.normal,
            4,
          ),
      );
    }
  }

  void _drawParticles(Canvas canvas, Size size) {
    for (final particle in particles) {
      final position = _screen(particle.pos, size);

      final paint = Paint()
        ..color = Colors.orangeAccent.withValues(
          alpha: particle.life.clamp(0, 1),
        );

      canvas.drawCircle(
        position,
        particle.size,
        paint,
      );
    }
  }

  void _drawShip(Canvas canvas, Size size) {
    final position = _screen(shipPosition, size);

    final angle = atan2(
      targetPosition.dy - shipPosition.dy,
      targetPosition.dx - shipPosition.dx,
    ) +
        pi / 2;

    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(angle);

    final glowPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        8,
      );

    canvas.drawCircle(
      const Offset(0, 4),
      12,
      glowPaint,
    );

    final shipPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final ship = Path()
      ..moveTo(0, -13)
      ..lineTo(8, 10)
      ..lineTo(0, 6)
      ..lineTo(-8, 10)
      ..close();

    canvas.drawPath(ship, shipPaint);

    final enginePaint = Paint()
      ..color = Colors.orangeAccent;

    canvas.drawCircle(
      const Offset(0, 10),
      3,
      enginePaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ArcadePainter oldDelegate) {
    return true;
  }
}

class _Alien {
  Offset pos;
  Offset velocity;
  double phase;
  bool alive;

  _Alien({
    required this.pos,
    required this.velocity,
    required this.phase,
    required this.alive,
  });
}

class _Laser {
  Offset pos;
  Offset previousPos;
  Offset velocity;
  double life;

  _Laser({
    required this.pos,
    required this.velocity,
    required this.life,
  }) : previousPos = pos;
}

class _ExplosionParticle {
  Offset pos;
  Offset velocity;
  double life;
  double size;

  _ExplosionParticle({
    required this.pos,
    required this.velocity,
    required this.life,
    required this.size,
  });
}

class _Star {
  Offset pos;
  final double speed;
  final double size;
  final double opacity;

  _Star({
    required this.pos,
    required this.speed,
    required this.size,
    required this.opacity,
  });
}