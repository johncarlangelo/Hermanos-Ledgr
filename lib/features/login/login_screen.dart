// Login screen matching Stitch design with staggered animations.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/neumorphic_box.dart';
import '../../core/widgets/animations.dart';

class LoginScreen extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onSkip;

  const LoginScreen({
    super.key,
    required this.onLogin,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // App Icon — scale in
                ScaleIn(
                  delayMs: 200,
                  child: NeumorphicContainer(
                    state: NeumorphicState.extruded,
                    borderRadius: 20,
                    padding: const EdgeInsets.all(20),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                FadeSlideIn(
                  delayMs: 400,
                  child: Text(
                    'Hermanos Ledgr',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Tagline
                FadeSlideIn(
                  delayMs: 550,
                  child: Text(
                    'Mindful financial planning.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),

                const Spacer(flex: 1),

                // Google Sign-In Button
                FadeSlideIn(
                  delayMs: 700,
                  child: NeumorphicButton(
                    onPressed: onLogin,
                    borderRadius: 28,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'G',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4285F4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Continue with Google',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textCharcoal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Description
                FadeSlideIn(
                  delayMs: 850,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Sign in with Google to automatically backup your budget data and settings to your personal Google Drive. Keep your data synced between devices seamlessly.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 1),

                // Skip Button
                FadeSlideIn(
                  delayMs: 1000,
                  child: NeumorphicButton(
                    onPressed: onSkip,
                    borderRadius: 28,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    child: Text(
                      'Skip for now',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
