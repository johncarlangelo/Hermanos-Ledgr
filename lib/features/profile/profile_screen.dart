// Profile screen with staggered animations.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/neumorphic_box.dart';
import '../../core/widgets/animations.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onLogout;
  final String userName;

  const ProfileScreen({
    super.key,
    required this.onLogout,
    this.userName = 'User',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true, backgroundColor: AppColors.background, elevation: 0,
            title: Text('Hermanos Ledgr', style: GoogleFonts.plusJakartaSans(
              fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary,
            )),
            centerTitle: true,
            actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.settings_rounded, color: AppColors.primary))],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),
                ScaleIn(delayMs: 200, child: Center(
                  child: NeumorphicSunkenContainer(
                    borderRadius: 50, width: 100, height: 100, padding: EdgeInsets.zero,
                    child: const Center(child: Icon(Icons.person_outline_rounded, size: 48, color: AppColors.onSurfaceVariant)),
                  ),
                )),
                const SizedBox(height: 20),
                FadeSlideIn(delayMs: 350, child: Center(child: Text(userName, style: GoogleFonts.plusJakartaSans(
                  fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textCharcoal,
                )))),
                const SizedBox(height: 28),
                FadeSlideIn(delayMs: 450, child: NeumorphicButton(
                  onPressed: () {}, borderRadius: 12, padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.swap_horiz_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text('Switch Account', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ]),
                )),
                const SizedBox(height: 12),
                FadeSlideIn(delayMs: 550, child: NeumorphicButton(
                  onPressed: onLogout, borderRadius: 12, padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    Text('Logout', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.error)),
                  ]),
                )),
                const SizedBox(height: 28),
                FadeSlideIn(delayMs: 650, child: Row(children: [
                  Expanded(child: NeumorphicContainer(
                    state: NeumorphicState.extruded, borderRadius: 12, padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(children: [
                      Text('12', style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      const SizedBox(height: 4),
                      Text('TRANSACTIONS', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing: 0.6)),
                    ]),
                  )),
                  const SizedBox(width: 16),
                  Expanded(child: NeumorphicContainer(
                    state: NeumorphicState.extruded, borderRadius: 12, padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(children: [
                      Text('4', style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      const SizedBox(height: 4),
                      Text('CATEGORIES', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing: 0.6)),
                    ]),
                  )),
                ])),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
