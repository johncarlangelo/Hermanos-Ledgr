/// Add Transaction modal matching Stitch design:
/// - Expense/Income tab toggle
/// - Amount input with ₱ symbol
/// - Title field
/// - Category chips (expense) / Source grid (income)
/// - Note field
/// - Quick Add grid (expense)
/// - Save Record button
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/neumorphic_box.dart';

class AddTransactionModal extends StatefulWidget {
  const AddTransactionModal({super.key});

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  bool _isExpense = true;
  String? _selectedCategory;
  String? _selectedSource;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              // ── Drag Handle ──
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Tab Toggle ──
              NeumorphicContainer(
                state: NeumorphicState.extruded,
                borderRadius: 28,
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _tabButton('Expense', _isExpense, () => setState(() => _isExpense = true)),
                    _tabButton('Income', !_isExpense, () => setState(() => _isExpense = false)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Amount ──
              NeumorphicSunkenContainer(
                borderRadius: 12,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      _isExpense ? 'AMOUNT' : 'Amount',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₱ 0.00',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textCharcoal,
                        letterSpacing: -0.96,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Title Field ──
              NeumorphicContainer(
                state: NeumorphicState.extruded,
                borderRadius: 12,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    if (_isExpense) ...[
                      const Icon(Icons.edit_rounded, color: AppColors.onSurfaceVariant, size: 18),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'What is this for?',
                          border: InputBorder.none,
                          hintStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.onSurfaceVariant),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          isDense: true,
                        ),
                        style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textCharcoal),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Categories (Expense) or Sources (Income) ──
              if (_isExpense) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _expenseCategories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: NeumorphicContainer(
                        state: isSelected ? NeumorphicState.sunken : NeumorphicState.extruded,
                        borderRadius: 20,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Text(cat, style: GoogleFonts.plusJakartaSans(
                          fontSize: 13, fontWeight: FontWeight.w500,
                          color: isSelected ? AppColors.primary : AppColors.textCharcoal,
                        )),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],

              // ── Note Field ──
              NeumorphicContainer(
                state: NeumorphicState.extruded,
                borderRadius: 12,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.notes_rounded, color: AppColors.onSurfaceVariant, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Add a note (optional)',
                          border: InputBorder.none,
                          hintStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.onSurfaceVariant),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          isDense: true,
                        ),
                        style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textCharcoal),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Quick Add / Source Grid ──
              Text(
                _isExpense ? 'Quick Add' : 'Source',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textCharcoal,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.8,
                children: (_isExpense ? _quickAddItems : _sourceItems).map((item) {
                  final isSelected = _isExpense
                      ? _selectedCategory == item.label
                      : _selectedSource == item.label;
                  return GestureDetector(
                    onTap: () => setState(() {
                      if (_isExpense) {
                        _selectedCategory = item.label;
                      } else {
                        _selectedSource = item.label;
                      }
                    }),
                    child: NeumorphicContainer(
                      state: isSelected ? NeumorphicState.sunken : NeumorphicState.extruded,
                      borderRadius: 12,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Icon(item.icon, size: 18, color: item.color),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(item.label, style: GoogleFonts.plusJakartaSans(
                              fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textCharcoal,
                            ), overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // ── Save Button ──
              NeumorphicButton(
                onPressed: () => Navigator.pop(context),
                borderRadius: 28,
                padding: const EdgeInsets.symmetric(vertical: 16),
                color: AppColors.background,
                child: Center(
                  child: Text('Save Record', style: GoogleFonts.plusJakartaSans(
                    fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary,
                  )),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _tabButton(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.background : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            boxShadow: isActive ? const [
              BoxShadow(color: AppColors.shadowDark, offset: Offset(2, 2), blurRadius: 6),
              BoxShadow(color: AppColors.shadowLight, offset: Offset(-2, -2), blurRadius: 6),
            ] : null,
          ),
          child: Center(
            child: Text(label, style: GoogleFonts.plusJakartaSans(
              fontSize: 15, fontWeight: FontWeight.w600,
              color: isActive ? AppColors.textCharcoal : AppColors.onSurfaceVariant,
            )),
          ),
        ),
      ),
    );
  }
}

// ── Mock Data ──
const _expenseCategories = ['Food & Drinks', 'Transport', 'Shopping', 'Entertainment', 'Bills'];

class _GridItem {
  final IconData icon;
  final String label;
  final Color color;
  const _GridItem(this.icon, this.label, this.color);
}

const _quickAddItems = [
  _GridItem(Icons.local_cafe_rounded, 'Coffee Run', Color(0xFF795548)),
  _GridItem(Icons.restaurant_rounded, 'Dining', Color(0xFFFF7043)),
  _GridItem(Icons.account_balance_wallet_rounded, 'E-Wallet...', Color(0xFF42A5F5)),
  _GridItem(Icons.phone_android_rounded, 'E-Load', Color(0xFF66BB6A)),
  _GridItem(Icons.music_note_rounded, 'Spotify', Color(0xFF1DB954)),
  _GridItem(Icons.play_arrow_rounded, 'Netflix', Color(0xFFE50914)),
  _GridItem(Icons.add_circle_outline_rounded, 'Other So...', AppColors.onSurfaceVariant),
];

const _sourceItems = [
  _GridItem(Icons.person_rounded, 'Sent to Me', AppColors.primary),
  _GridItem(Icons.account_balance_wallet_rounded, 'GCash Transfer', Color(0xFF007DFE)),
  _GridItem(Icons.account_balance_wallet_rounded, 'Maya Transfer', Color(0xFF00B140)),
  _GridItem(Icons.account_balance_rounded, 'MariBank Transfer', Color(0xFFD4A017)),
  _GridItem(Icons.account_balance_rounded, 'Bank Transfer', AppColors.onSurfaceVariant),
  _GridItem(Icons.more_horiz_rounded, 'Other Sources', AppColors.onSurfaceVariant),
];
