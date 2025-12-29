import 'package:flutter/material.dart';

void main() {
  runApp(const NyayaDrishtiApp());
}

class NyayaDrishtiApp extends StatelessWidget {
  const NyayaDrishtiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nyaya-Drishti',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      home: const RoleSelectionScreen(),
    );
  }
}

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _cardsController;
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;
  String? _selectedRole;

  @override
  void initState() {
    super.initState();

    // Header animation controller
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _headerSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _headerController,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
          ),
        );

    // Cards animation controller
    _cardsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Start animations
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardsController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _cardsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A1929), Color(0xFF1A2332), Color(0xFF0D47A1)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),

                // Animated Header Section
                FadeTransition(
                  opacity: _headerFadeAnimation,
                  child: SlideTransition(
                    position: _headerSlideAnimation,
                    child: _buildHeader(),
                  ),
                ),

                const SizedBox(height: 64),

                // Animated Role Cards Section
                _buildAnimatedRoleCard(
                  delay: 0,
                  title: 'Lawyer',
                  description: 'Manage cases, clients, and court appearances',
                  icon: Icons.work_outline,
                  roleId: 'lawyer',
                ),

                const SizedBox(height: 16),

                _buildAnimatedRoleCard(
                  delay: 150,
                  title: 'Court Master',
                  description: 'Schedule hearings and coordinate proceedings',
                  icon: Icons.account_balance_outlined,
                  roleId: 'master',
                ),

                const SizedBox(height: 16),

                _buildAnimatedRoleCard(
                  delay: 300,
                  title: 'Judge',
                  description: 'Preside over cases and manage courtroom',
                  icon: Icons.gavel_outlined,
                  roleId: 'judge',
                ),

                const SizedBox(height: 40),

                // Animated Footer
                FadeTransition(
                  opacity: _headerFadeAnimation,
                  child: _buildFooter(),
                ),

                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Animated App Icon with glow effect
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1500),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF64B5F6).withOpacity(0.6),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.balance,
                  color: Color(0xFF0D47A1),
                  size: 40,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        // App Name with shimmer effect
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Color(0xFF90CAF9), Colors.white],
          ).createShader(bounds),
          child: const Text(
            'Nyaya-Drishti',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Subtitle
        const Text(
          'Digital Court Scheduling & Case Management',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFFB0BEC5),
            fontWeight: FontWeight.w500,
            height: 1.4,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedRoleCard({
    required int delay,
    required String title,
    required String description,
    required IconData icon,
    required String roleId,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800 + delay),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        // Clamp value to ensure it's between 0.0 and 1.0
        final clampedValue = value.clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(0, 50 * (1 - clampedValue)),
          child: Opacity(
            opacity: clampedValue,
            child: RoleCard(
              title: title,
              description: description,
              icon: icon,
              roleId: roleId,
              isSelected: _selectedRole == roleId,
              onTap: () {
                setState(() {
                  _selectedRole = roleId;
                });

                // Haptic feedback simulation and reset after delay
                Future.delayed(const Duration(milliseconds: 1500), () {
                  if (mounted) {
                    setState(() {
                      _selectedRole = null;
                    });
                  }
                });
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: const Text(
            'Select your official role to continue',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFFB0BEC5),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}

// Reusable Animated Role Card Widget
class RoleCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final String roleId;
  final bool isSelected;
  final VoidCallback onTap;

  const RoleCard({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.roleId,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  State<RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<RoleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(RoleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _pulseController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isHovering = true),
      onTapUp: (_) {
        setState(() => _isHovering = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..scale(_isHovering ? 0.97 : 1.0)
          ..scale(widget.isSelected ? 1.03 : 1.0),
        child: Stack(
          children: [
            // Outer glow layer - always visible
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: widget.isSelected
                        ? const Color(0xFF42A5F5).withOpacity(0.6)
                        : const Color(0xFF1976D2).withOpacity(0.2),
                    blurRadius: widget.isSelected ? 35 : 25,
                    spreadRadius: widget.isSelected ? 2 : 0,
                  ),
                ],
              ),
            ),

            // Main card with glassmorphism effect
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(width: 3, color: Colors.transparent),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.isSelected
                        ? [
                            const Color(0xFF1E88E5),
                            const Color(0xFF1565C0),
                            const Color(0xFF0D47A1),
                          ]
                        : [
                            Colors.white,
                            const Color(0xFFFAFAFA),
                            const Color(0xFFF5F5F5),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    // Main shadow
                    BoxShadow(
                      color: widget.isSelected
                          ? const Color(0xFF1976D2).withOpacity(0.5)
                          : Colors.black.withOpacity(0.12),
                      blurRadius: widget.isSelected ? 25 : 18,
                      spreadRadius: widget.isSelected ? 3 : 1,
                      offset: const Offset(0, 10),
                    ),
                    // Secondary shadow for depth
                    BoxShadow(
                      color: widget.isSelected
                          ? const Color(0xFF0D47A1).withOpacity(0.4)
                          : const Color(0xFF1976D2).withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Animated border gradient
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(width: 0, color: Colors.transparent),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: widget.isSelected
                                ? [
                                    const Color(0xFF64B5F6),
                                    const Color(0xFF42A5F5),
                                    const Color(0xFF2196F3),
                                  ]
                                : [
                                    const Color(0xFF1976D2).withOpacity(0.4),
                                    const Color(0xFF1565C0).withOpacity(0.3),
                                    const Color(0xFF0D47A1).withOpacity(0.4),
                                  ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(2.5),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: widget.isSelected
                                    ? [
                                        const Color(0xFF1E88E5),
                                        const Color(0xFF1565C0),
                                        const Color(0xFF0D47A1),
                                      ]
                                    : [
                                        Colors.white,
                                        const Color(0xFFFAFAFA),
                                        const Color(0xFFF5F5F5),
                                      ],
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: widget.isSelected
                                      ? [
                                          Colors.white.withOpacity(0.2),
                                          Colors.transparent,
                                        ]
                                      : [
                                          const Color(
                                            0xFF64B5F6,
                                          ).withOpacity(0.08),
                                          Colors.transparent,
                                        ],
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(22.0),
                                child: Row(
                                  children: [
                                    // Icon Container with pulse animation and enhanced border
                                    AnimatedBuilder(
                                      animation: _pulseController,
                                      builder: (context, child) {
                                        final pulseValue =
                                            _pulseController.value;
                                        return Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: widget.isSelected
                                                  ? [
                                                      Colors.white.withOpacity(
                                                        0.25,
                                                      ),
                                                      Colors.white.withOpacity(
                                                        0.15,
                                                      ),
                                                    ]
                                                  : [
                                                      const Color(
                                                        0xFF1976D2,
                                                      ).withOpacity(0.12),
                                                      const Color(
                                                        0xFF0D47A1,
                                                      ).withOpacity(0.08),
                                                    ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: widget.isSelected
                                                  ? Colors.white.withOpacity(
                                                      0.5,
                                                    )
                                                  : const Color(
                                                      0xFF1976D2,
                                                    ).withOpacity(0.35),
                                              width: 2.5,
                                            ),
                                            boxShadow: [
                                              if (widget.isSelected)
                                                BoxShadow(
                                                  color: Colors.white
                                                      .withOpacity(
                                                        0.3 * (1 - pulseValue),
                                                      ),
                                                  blurRadius: 20 * pulseValue,
                                                  spreadRadius: 10 * pulseValue,
                                                ),
                                              BoxShadow(
                                                color: widget.isSelected
                                                    ? Colors.white.withOpacity(
                                                        0.2,
                                                      )
                                                    : const Color(
                                                        0xFF1976D2,
                                                      ).withOpacity(0.15),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            widget.icon,
                                            color: widget.isSelected
                                                ? Colors.white
                                                : const Color(0xFF0D47A1),
                                            size: 30,
                                          ),
                                        );
                                      },
                                    ),

                                    const SizedBox(width: 20),

                                    // Text Content
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.title,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: widget.isSelected
                                                  ? Colors.white
                                                  : const Color(0xFF0A1929),
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            widget.description,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: widget.isSelected
                                                  ? Colors.white.withOpacity(
                                                      0.9,
                                                    )
                                                  : const Color(0xFF546E7A),
                                              height: 1.4,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    // Arrow Icon with bounce animation
                                    TweenAnimationBuilder<double>(
                                      tween: Tween(
                                        begin: 0.0,
                                        end: widget.isSelected ? 1.0 : 0.0,
                                      ),
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      builder: (context, value, child) {
                                        return Transform.translate(
                                          offset: Offset(5 * value, 0),
                                          child: Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            color: widget.isSelected
                                                ? Colors.white
                                                : const Color(0xFF90A4AE),
                                            size: 18,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
