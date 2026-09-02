import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const ArcadeClickerApp());
}

class ArcadeClickerApp extends StatelessWidget {
  const ArcadeClickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Neon Arcade Clicker',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0E17),
      ),
      home: const ArcadeClickerPage(),
    );
  }
}

class ArcadeClickerPage extends StatefulWidget {
  const ArcadeClickerPage({super.key});

  @override
  State<ArcadeClickerPage> createState() => _ArcadeClickerPageState();
}

class _ArcadeClickerPageState extends State<ArcadeClickerPage> with SingleTickerProviderStateMixin {
  int score = 0;
  int clickPower = 1;
  int autoClickerCount = 0;
  int clickerUpgradeCost = 10;
  int autoClickerCost = 50;

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 80),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Пассивный доход каждую секунду
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (autoClickerCount > 0) {
        setState(() {
          score += autoClickerCount;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _handleClick() {
    setState(() {
      score += clickPower;
    });
    _controller.forward().then((_) => _controller.reverse());
  }

  void _buyClickPower() {
    if (score >= clickerUpgradeCost) {
      setState(() {
        score -= clickerUpgradeCost;
        clickPower += 1;
        clickerUpgradeCost = (clickerUpgradeCost * 1.5).round();
      });
    }
  }

  void _buyAutoClicker() {
    if (score >= autoClickerCost) {
      setState(() {
        score -= autoClickerCost;
        autoClickerCount += 1;
        autoClickerCost = (autoClickerCost * 1.6).round();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'NEON CLICKER',
          style: TextStyle(
            color: Color(0xFF00F0FF),
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Счётчик и статистика
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'SCORE: $score',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFF007F),
                      shadows: [
                        Shadow(blurRadius: 15.0, color: Color(0xFFFF007F), offset: Offset(0, 0)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Power: +$clickPower / tap  |  Auto: +$autoClickerCount / s',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            // Главная неоновая кнопка
            Center(
              child: GestureDetector(
                onTapDown: (_) => _handleClick(),
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF007F), Color(0xFF00F0FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00F0FF).withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'TAP!',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 3.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Магазин улучшений
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF161522),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'UPGRADES SHOP',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00F0FF),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Stronger Taps (+1)', style: TextStyle(fontWeight: FontWeight.w500)),
                          Text('Cost: $clickerUpgradeCost pts', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: score >= clickerUpgradeCost ? _buyClickPower : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF007F),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('BUY'),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: Colors.white24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Auto-Clicker (+1/s)', style: TextStyle(fontWeight: FontWeight.w500)),
                          Text('Cost: $autoClickerCost pts', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: score >= autoClickerCost ? _buyAutoClicker : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00F0FF),
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('BUY'),
                      ),
                    ],
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
