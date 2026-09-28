/// AI Financial Advisor chat screen matching Stitch design:
/// - Chat bubbles: AI (left, gray) and User (right, green)
/// - Online/Offline status
/// - Budget proposal card with Apply action
/// - Message input field
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/neumorphic_box.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Column(
          children: [
            Text('AI Financial Advisor', style: GoogleFonts.plusJakartaSans(
              fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textCharcoal,
            )),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle,
                )),
                const SizedBox(width: 4),
                Text('Offline', style: GoogleFonts.plusJakartaSans(
                  fontSize: 11, color: AppColors.onSurfaceVariant,
                )),
              ],
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert_rounded, color: AppColors.onSurfaceVariant)),
        ],
      ),
      body: Column(
        children: [
          // ── Chat Messages ──
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _dateLabel('Today, 10:42 AM'),
                const SizedBox(height: 12),
                _aiBubble(
                  'Hello! I\'ve analyzed your recent spending patterns. It looks like your dining out expenses are 15% higher this month compared to last. Would you like me to suggest a budget adjustment?',
                ),
                const SizedBox(height: 12),
                _userBubble(
                  'Yes, that would be helpful. I didn\'t realize I spent that much. Can we aim to save ₱50 next month?',
                ),
                const SizedBox(height: 12),
                _aiBubble(
                  'Absolutely. To save ₱50 next month on dining, I recommend setting a weekly limit of ₱45 for restaurants and takeout.',
                ),
                const SizedBox(height: 8),
                _proposalCard(),
                const SizedBox(height: 12),
                _userBubble('Sounds like a plan. Apply that to my main budget.'),
                const SizedBox(height: 12),
                _aiBubble(
                  'Budget updated successfully. You are now tracking towards a ₱50 saving for next month. Keep it up! 🎉',
                ),
              ],
            ),
          ),

          // ── Input Field ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: const BoxDecoration(
              color: AppColors.background,
              boxShadow: [BoxShadow(color: AppColors.shadowDark, offset: Offset(0, -2), blurRadius: 8)],
            ),
            child: SafeArea(
              top: false,
              child: NeumorphicSunkenContainer(
                borderRadius: 28,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Ask about your budget...',
                          border: InputBorder.none,
                          hintStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.onSurfaceVariant),
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textCharcoal),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.send_rounded, color: AppColors.primary, size: 22),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateLabel(String text) {
    return Center(
      child: Text(text, style: GoogleFonts.plusJakartaSans(
        fontSize: 12, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500,
      )),
    );
  }

  Widget _aiBubble(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Text(text, style: GoogleFonts.plusJakartaSans(
          fontSize: 14, color: AppColors.textCharcoal, height: 1.5,
        )),
      ),
    );
  }

  Widget _userBubble(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Text(text, style: GoogleFonts.plusJakartaSans(
          fontSize: 14, color: Colors.white, height: 1.5,
        )),
      ),
    );
  }

  Widget _proposalCard() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
        margin: const EdgeInsets.only(left: 8),
        child: NeumorphicContainer(
          state: NeumorphicState.extruded,
          borderRadius: 12,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dining Budget Proposal', style: GoogleFonts.plusJakartaSans(
                fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textCharcoal,
              )),
              const SizedBox(height: 4),
              Text('₱45 / week limit', style: GoogleFonts.plusJakartaSans(
                fontSize: 13, color: AppColors.onSurfaceVariant,
              )),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  ),
                  child: Text('Apply', style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary,
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
