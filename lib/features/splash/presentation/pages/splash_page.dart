import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucid_state_app/app/router/routes.dart';
import 'package:lucid_state_app/core/services/local_storage_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Timer _warmupGuardTimer;

  bool _isAnimationComplete = false;
  bool _isImageWarmupComplete = false;
  bool _hasNavigated = false;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _titleOpacity;
  late final Animation<double> _taglineOpacity;
  late final Animation<double> _progress;
  late final Animation<double> _pageFadeOut;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _isAnimationComplete = true;
          _navigateWhenReady();
        }
      })
      ..forward();

    _warmupGuardTimer = Timer(const Duration(milliseconds: 3200), () {
      _isImageWarmupComplete = true;
      _navigateWhenReady();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _warmUpImages();
    });

    _logoScale = Tween<double>(begin: 0.78, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.48, curve: Curves.easeOutBack),
      ),
    );

    _logoOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.44, curve: Curves.easeOut),
    );

    _titleOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.24, 0.66, curve: Curves.easeOut),
    );

    _taglineOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.58, 0.9, curve: Curves.easeOut),
    );

    _progress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeInOutCubic),
    );

    _pageFadeOut = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.9, 1.0, curve: Curves.easeIn),
      ),
    );
  }

  bool _isImageAssetPath(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif');
  }

  Future<void> _warmUpImages() async {
    try {
      final manifestJson = await rootBundle.loadString('AssetManifest.json');
      final manifest = jsonDecode(manifestJson) as Map<String, dynamic>;

      final imageAssets = manifest.keys
          .where((path) => path.startsWith('assets/') && _isImageAssetPath(path))
          .toList();

      for (final path in imageAssets) {
        if (!mounted) {
          return;
        }

        await precacheImage(AssetImage(path), context);
      }
    } catch (_) {
      // Ignore warm-up errors and continue app flow.
    }

    if (!mounted) {
      return;
    }

    _isImageWarmupComplete = true;
    _navigateWhenReady();
  }

  void _navigateWhenReady() {
    if (!mounted || _hasNavigated) {
      return;
    }

    if (!_isAnimationComplete || !_isImageWarmupComplete) {
      return;
    }

    _hasNavigated = true;
    
    // 🔍 Check apakah sudah ada user_id tersimpan (sudah pernah login)
    final localStorage = LocalStorageService();
    final savedUserId = localStorage.getGuestUserId();
    
    if (savedUserId != null) {
      print('✅ User already logged in (guest): $savedUserId');
      print('   → Redirect ke dashboard');
      context.go(AppRoutes.dashboard);
    } else {
      print('⚠️ No saved user_id found');
      print('   → Redirect ke login');
      context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _warmupGuardTimer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final logoSize = size.width * 0.26;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final floatOffset = math.sin(_controller.value * math.pi) * 7;
          final pulse =
              ((math.sin(_controller.value * math.pi * 3.4) + 1) / 2) * 0.9;

          return Opacity(
            opacity: _pageFadeOut.value,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1D1F85),
                    Color(0xFF34229A),
                    Color(0xFF7023CC),
                  ],
                  stops: [0.0, 0.57, 1.0],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: -140,
                    left: -20,
                    right: -20,
                    child: IgnorePointer(
                      child: Container(
                        height: 280,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Color(0x66B57BFF),
                              Color(0x00000000),
                            ],
                            stops: [0.1, 1],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Column(
                      children: [
                        const Spacer(flex: 5),
                        Transform.translate(
                          offset: Offset(0, floatOffset),
                          child: Opacity(
                            opacity: _logoOpacity.value,
                            child: Transform.scale(
                              scale: _logoScale.value,
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: logoSize,
                                    height: logoSize,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: logoSize * (1.04 + pulse * 0.12),
                                          height: logoSize * (1.04 + pulse * 0.12),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: const Color(0xFFC8B9FF)
                                                .withValues(alpha: 0.12 + pulse * 0.09),
                                          ),
                                        ),
                                        Container(
                                          width: logoSize,
                                          height: logoSize,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: const Color(0xFFAFA4DA)
                                                  .withValues(alpha: 0.35),
                                              width: 2,
                                            ),
                                            color: const Color(0xFF9A8DE0)
                                                .withValues(alpha: 0.12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFFB99CFF)
                                                    .withValues(alpha: 0.12 + pulse * 0.15),
                                                blurRadius: 28 + (pulse * 8),
                                                spreadRadius: 2 + (pulse * 3),
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(14),
                                            child: Image.asset('assets/images/Logo.png'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 34),
                                  Opacity(
                                    opacity: _titleOpacity.value,
                                    child: Column(
                                      children: [
                                        Text(
                                          'LUCID',
                                          style: TextStyle(
                                            fontSize: size.width * 0.16,
                                            height: 0.95,
                                            fontStyle: FontStyle.italic,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'STATE',
                                          style: TextStyle(
                                            fontSize: size.width * 0.067,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFFC8AFE9),
                                            letterSpacing: 7,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Spacer(flex: 5),
                        Opacity(
                          opacity: _taglineOpacity.value,
                          child: Text(
                            'AWARENESS IN EVERY BREATH',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFFCFB7EE).withValues(alpha: 0.86),
                              fontSize: 20,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 44),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: Stack(
                              children: [
                                Container(
                                  height: 4,
                                  color: const Color(0xFFA48CD8).withValues(alpha: 0.32),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    height: 4,
                                    width: (size.width - 88) * _progress.value,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(999),
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFE9E0FF), Color(0xFFD3C4FF)],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
