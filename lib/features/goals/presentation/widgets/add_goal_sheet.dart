import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/app/theme/text_theme.dart';
import 'package:hermanos_ledgr/core/constants/app_constants.dart';
import 'package:hermanos_ledgr/core/utils/currency_formatter.dart';
import 'package:hermanos_ledgr/features/goals/domain/goal_model.dart';
import 'package:hermanos_ledgr/features/goals/presentation/widgets/goal_progress_ring.dart';
import 'package:hermanos_ledgr/features/goals/providers/goals_provider.dart';
import 'package:hermanos_ledgr/shared/widgets/undo_snackbar.dart';

/// Available categories for goal icon filtering.
const _kGoalCategories = [
  'All',
  'Vehicles',
  'Housing',
  'Tech',
  'Travel',
  'Finance',
  'Lifestyle',
];

/// Available icons for savings goals with categories.
const _kGoalIcons = [
  // ─── Vehicles & Transportation (15 icons) ───
  (Icons.directions_car_rounded, 'Car & Vehicle', 'Vehicles'),
  (Icons.time_to_leave_rounded, 'Automobile', 'Vehicles'),
  (Icons.electric_car_rounded, 'Electric Car / EV', 'Vehicles'),
  (Icons.car_rental_rounded, 'Sedan / Rental', 'Vehicles'),
  (Icons.airport_shuttle_rounded, 'Van & Shuttle', 'Vehicles'),
  (Icons.two_wheeler_rounded, 'Motorcycle & Scooter', 'Vehicles'),
  (Icons.pedal_bike_rounded, 'Bicycle & Cycling', 'Vehicles'),
  (Icons.electric_bike_rounded, 'E-Bike', 'Vehicles'),
  (Icons.electric_scooter_rounded, 'E-Scooter', 'Vehicles'),
  (Icons.car_repair_rounded, 'Car Repair & Service', 'Vehicles'),
  (Icons.local_gas_station_rounded, 'Fuel & Gas Fund', 'Vehicles'),
  (Icons.build_rounded, 'Auto Maintenance', 'Vehicles'),
  (Icons.speed_rounded, 'Performance & Tuning', 'Vehicles'),
  (Icons.commute_rounded, 'Daily Commute', 'Vehicles'),
  (Icons.local_taxi_rounded, 'Taxi & Rideshare', 'Vehicles'),

  // ─── Housing, Apartment & Moving (17 icons) ───
  (Icons.apartment_rounded, 'Apartment & Condo', 'Housing'),
  (Icons.home_rounded, 'House & Property', 'Housing'),
  (Icons.location_city_rounded, 'City High-Rise', 'Housing'),
  (Icons.domain_rounded, 'Real Estate', 'Housing'),
  (Icons.cottage_rounded, 'Cottage / Vacation Home', 'Housing'),
  (Icons.key_rounded, 'New Keys / Move-In', 'Housing'),
  (Icons.door_front_door_rounded, 'Front Door / Entry', 'Housing'),
  (Icons.local_shipping_rounded, 'Moving & Relocation', 'Housing'),
  (Icons.chair_rounded, 'Furniture & Decor', 'Housing'),
  (Icons.weekend_rounded, 'Living Room Couch', 'Housing'),
  (Icons.bed_rounded, 'Bedroom & Mattress', 'Housing'),
  (Icons.kitchen_rounded, 'Kitchen Appliances', 'Housing'),
  (Icons.construction_rounded, 'Renovation & Hardware', 'Housing'),
  (Icons.roofing_rounded, 'Roof & Structure', 'Housing'),
  (Icons.yard_rounded, 'Garden & Patio', 'Housing'),
  (Icons.water_damage_rounded, 'Plumbing & Repairs', 'Housing'),
  (Icons.power_rounded, 'Power & Utilities', 'Housing'),

  // ─── Tech, Electronics & Studio (13 icons) ───
  (Icons.smartphone_rounded, 'Smartphone Upgrade', 'Tech'),
  (Icons.laptop_mac_rounded, 'MacBook & Laptop', 'Tech'),
  (Icons.desktop_windows_rounded, 'Desktop PC / Rig', 'Tech'),
  (Icons.tablet_mac_rounded, 'Tablet & iPad', 'Tech'),
  (Icons.sports_esports_rounded, 'Gaming & Console', 'Tech'),
  (Icons.camera_alt_rounded, 'Camera & Photography', 'Tech'),
  (Icons.videocam_rounded, 'Video & Content Gear', 'Tech'),
  (Icons.headphones_rounded, 'Headphones & Audio', 'Tech'),
  (Icons.tv_rounded, '4K TV & Home Theater', 'Tech'),
  (Icons.speaker_rounded, 'Hi-Fi Speaker', 'Tech'),
  (Icons.watch_rounded, 'Smartwatch & Wearable', 'Tech'),
  (Icons.memory_rounded, 'GPU & Hardware', 'Tech'),
  (Icons.wifi_rounded, 'Smart Home & Network', 'Tech'),

  // ─── Travel & Adventure (11 icons) ───
  (Icons.flight_takeoff_rounded, 'Travel & Flights', 'Travel'),
  (Icons.beach_access_rounded, 'Beach Vacation', 'Travel'),
  (Icons.luggage_rounded, 'Trip & Luggage', 'Travel'),
  (Icons.hotel_rounded, 'Hotel & Staycation', 'Travel'),
  (Icons.explore_rounded, 'Adventure & Compass', 'Travel'),
  (Icons.terrain_rounded, 'Mountain Hiking', 'Travel'),
  (Icons.pool_rounded, 'Resort & Pool', 'Travel'),
  (Icons.sailing_rounded, 'Cruise & Boat', 'Travel'),
  (Icons.map_rounded, 'Roadtrip & Map', 'Travel'),
  (Icons.camera_rounded, 'Travel Memories', 'Travel'),
  (Icons.public_rounded, 'World Tour', 'Travel'),

  // ─── Savings & Finance (11 icons) ───
  (Icons.savings_rounded, 'Piggy Bank', 'Finance'),
  (Icons.account_balance_rounded, 'Bank & Vault', 'Finance'),
  (Icons.shield_rounded, 'Emergency Fund', 'Finance'),
  (Icons.lock_rounded, 'Security & Safe', 'Finance'),
  (Icons.trending_up_rounded, 'Stock Market & Growth', 'Finance'),
  (Icons.attach_money_rounded, 'Cash Reserve', 'Finance'),
  (Icons.credit_card_rounded, 'Debt Freedom', 'Finance'),
  (Icons.monetization_on_rounded, 'Gold & Coins', 'Finance'),
  (Icons.receipt_long_rounded, 'Tax & Sinking Fund', 'Finance'),
  (Icons.pie_chart_rounded, 'Portfolio', 'Finance'),
  (Icons.balance_rounded, 'Net Worth Milestone', 'Finance'),

  // ─── Life, Family & Celebrations (15 icons) ───
  (Icons.celebration_rounded, 'Celebration & Party', 'Lifestyle'),
  (Icons.diamond_rounded, 'Engagement & Wedding', 'Lifestyle'),
  (Icons.favorite_rounded, 'Health & Medical', 'Lifestyle'),
  (Icons.fitness_center_rounded, 'Fitness & Gym', 'Lifestyle'),
  (Icons.pets_rounded, 'Pets & Veterinary', 'Lifestyle'),
  (Icons.child_care_rounded, 'Baby & Nursery', 'Lifestyle'),
  (Icons.school_rounded, 'Education & Tuition', 'Lifestyle'),
  (Icons.menu_book_rounded, 'Books & Courses', 'Lifestyle'),
  (Icons.card_giftcard_rounded, 'Gifts & Holidays', 'Lifestyle'),
  (Icons.shopping_bag_rounded, 'Shopping & Wardrobe', 'Lifestyle'),
  (Icons.palette_rounded, 'Art & Creativity', 'Lifestyle'),
  (Icons.music_note_rounded, 'Music & Instrument', 'Lifestyle'),
  (Icons.restaurant_rounded, 'Dining & Foodie', 'Lifestyle'),
  (Icons.local_cafe_rounded, 'Coffee & Espresso', 'Lifestyle'),
  (Icons.stars_rounded, 'Special Milestone', 'Lifestyle'),
];

/// Curated Stash color palette for savings goals.
const _kGoalColors = [
  Color(0xFF00897B), // Stash Teal (Primary)
  Color(0xFF0D9488), // Mint Teal
  Color(0xFF2E7D52), // Forest Green
  Color(0xFF10B981), // Emerald
  Color(0xFF3F51B5), // Sapphire Indigo
  Color(0xFF2563EB), // Cobalt Blue
  Color(0xFF06B6D4), // Cyan Sky
  Color(0xFF8B5CF6), // Royal Violet
  Color(0xFF9333EA), // Deep Purple
  Color(0xFFEC4899), // Rose Pink
  Color(0xFFE11D48), // Ruby Red
  Color(0xFFFF7043), // Coral Orange
  Color(0xFFF59E0B), // Amber Gold
  Color(0xFFEAB308), // Sunflower
];

/// Custom bottom sheet for creating or editing a savings goal.
/// Strictly follows Zero Stock Android Native UI with custom sheets,
/// tactile icon pickers, and live preview.
class AddGoalSheet extends ConsumerStatefulWidget {
  final GoalModel? initialGoal;

  const AddGoalSheet({
    super.key,
    this.initialGoal,
  });

  static Future<void> show(BuildContext context, {GoalModel? goal}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => AddGoalSheet(initialGoal: goal),
    );
  }

  static Future<void> edit(BuildContext context, GoalModel goal) {
    return show(context, goal: goal);
  }

  @override
  ConsumerState<AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends ConsumerState<AddGoalSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _targetController;
  late final TextEditingController _currentController;

  late IconData _selectedIcon;
  late Color _selectedColor;
  DateTime? _selectedTargetDate;

  bool get isEditing => widget.initialGoal != null;

  @override
  void initState() {
    super.initState();
    final g = widget.initialGoal;
    _nameController = TextEditingController(text: g?.name ?? '');
    _targetController = TextEditingController(
      text: g != null && g.targetAmount > 0
          ? g.targetAmount.toStringAsFixed(0)
          : '',
    );
    _currentController = TextEditingController(
      text: g != null && g.currentAmount > 0
          ? g.currentAmount.toStringAsFixed(0)
          : '',
    );

    _selectedIcon = g?.icon ?? Icons.savings_rounded;
    _selectedColor = g?.color ?? _kGoalColors.first;
    _selectedTargetDate = g?.targetDate;

    _nameController.addListener(() => setState(() {}));
    _targetController.addListener(() => setState(() {}));
    _currentController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    super.dispose();
  }

  String _selectedCategory = 'All';

  double get _targetAmount => double.tryParse(_targetController.text) ?? 0.0;
  double get _currentAmount => double.tryParse(_currentController.text) ?? 0.0;

  String get _selectedIconLabel {
    for (final (icon, label, _) in _kGoalIcons) {
      if (icon == _selectedIcon) return label;
    }
    return 'Custom Icon';
  }

  List<(IconData, String, String)> get _filteredIcons {
    if (_selectedCategory == 'All') return _kGoalIcons;
    return _kGoalIcons.where((item) => item.$3 == _selectedCategory).toList();
  }

  void _saveGoal() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      UndoSnackbar.error(context, message: 'Please enter a goal name');
      return;
    }

    if (_targetAmount <= 0) {
      UndoSnackbar.error(context, message: 'Please enter a target amount');
      return;
    }

    HapticFeedback.mediumImpact();

    final goal = GoalModel(
      id: widget.initialGoal?.id ??
          'goal_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      targetAmount: _targetAmount,
      currentAmount: _currentAmount,
      targetDate: _selectedTargetDate,
      icon: _selectedIcon,
      color: _selectedColor,
      isCompleted: _currentAmount >= _targetAmount,
    );

    if (isEditing) {
      ref.read(goalsProvider.notifier).updateGoal(goal);
      Navigator.of(context).pop();
      UndoSnackbar.info(
        context,
        message: 'Goal updated: $name',
      );
    } else {
      ref.read(goalsProvider.notifier).addGoal(goal);
      Navigator.of(context).pop();
      UndoSnackbar.info(
        context,
        message: 'Created goal: $name',
      );
    }
  }

  void _showMonthYearPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        final now = DateTime.now();
        // Generate upcoming 36 months
        final months = List.generate(36, (i) {
          return DateTime(now.year, now.month + i + 1, 1);
        });

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Target Completion Date',
                      style: Theme.of(sheetContext)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.of(sheetContext).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.sm),
                // No deadline option
                ListTile(
                  leading: const Icon(Icons.all_inclusive_rounded),
                  title: const Text('No deadline (Open-ended)'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  selected: _selectedTargetDate == null,
                  onTap: () {
                    setState(() => _selectedTargetDate = null);
                    Navigator.of(sheetContext).pop();
                  },
                ),
                const Divider(),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 260),
                  child: ListView.builder(
                    itemCount: months.length,
                    itemBuilder: (ctx, idx) {
                      final m = months[idx];
                      final isSelected = _selectedTargetDate != null &&
                          _selectedTargetDate!.year == m.year &&
                          _selectedTargetDate!.month == m.month;

                      return ListTile(
                        leading: const Icon(Icons.calendar_month_rounded, size: 20),
                        title: Text(
                          DateFormat('MMMM yyyy').format(m),
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle_rounded,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                        selected: isSelected,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        onTap: () {
                          setState(() => _selectedTargetDate = m);
                          Navigator.of(sheetContext).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // Temporary goal for live run-rate calculation
    final previewGoal = GoalModel(
      id: 'preview',
      name: _nameController.text.trim().isEmpty ? 'My Goal' : _nameController.text.trim(),
      targetAmount: _targetAmount > 0 ? _targetAmount : 10000,
      currentAmount: _currentAmount,
      targetDate: _selectedTargetDate,
      icon: _selectedIcon,
      color: _selectedColor,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Edit Savings Goal' : 'New Savings Goal',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),

            // Live Mini Preview Card
            Container(
              padding: const EdgeInsets.all(Spacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _selectedColor.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  GoalProgressRing(
                    percentage: previewGoal.percentage,
                    color: _selectedColor,
                    size: 46,
                    strokeWidth: 4,
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          previewGoal.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${CurrencyFormatter.format(previewGoal.currentAmount)} of ${CurrencyFormatter.format(previewGoal.targetAmount)}',
                          style: moneyStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (previewGoal.monthlyContributionNeeded > 0)
                          Text(
                            'Pace: ${CurrencyFormatter.format(previewGoal.monthlyContributionNeeded)}/mo',
                            style: moneyStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _selectedColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_selectedIcon, size: 20, color: _selectedColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.lg),

            // Goal Name Field
            Text(
              'GOAL NAME',
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'e.g. Emergency Fund, Japan Trip',
                prefixIcon: const Icon(Icons.flag_outlined, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: Spacing.md),

            // Target Amount & Initial Saved Amount
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TARGET AMOUNT',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      TextField(
                        controller: _targetController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: moneyStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          prefixText: '${AppConstants.currencySymbol} ',
                          hintText: '50000',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CURRENT SAVED',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      TextField(
                        controller: _currentController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: moneyStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          prefixText: '${AppConstants.currencySymbol} ',
                          hintText: '0',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),

            // Target Completion Date Tile
            Text(
              'TARGET DEADLINE',
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            InkWell(
              onTap: _showMonthYearPicker,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.md - 2,
                ),
                decoration: BoxDecoration(
                  color: isDark ? StashColors.raised : theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 19,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: Text(
                        _selectedTargetDate != null
                            ? DateFormat('MMMM yyyy').format(_selectedTargetDate!)
                            : 'No deadline set (Open-ended)',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _selectedTargetDate != null
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Spacing.lg),

            // Icon Picker Header with Selected Label
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CHOOSE ICON',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  _selectedIconLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.xs),
            // Category Filter Chips
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _kGoalCategories.length,
                separatorBuilder: (_, _) => const SizedBox(width: Spacing.xs),
                itemBuilder: (ctx, i) {
                  final cat = _kGoalCategories[i];
                  final isCatSelected = _selectedCategory == cat;

                  return InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedCategory = cat);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isCatSelected
                            ? _selectedColor
                            : (isDark ? StashColors.raised : theme.colorScheme.surfaceContainerHigh),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isCatSelected
                              ? _selectedColor
                              : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 11,
                          fontWeight: isCatSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isCatSelected
                              ? Colors.white
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: Spacing.sm),

            // Icon Picker Grid
            SizedBox(
              height: 112,
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: Spacing.sm,
                  crossAxisSpacing: Spacing.sm,
                  childAspectRatio: 1.0,
                ),
                itemCount: _filteredIcons.length,
                itemBuilder: (ctx, i) {
                  final (icon, tooltip, _) = _filteredIcons[i];
                  final isSelected = _selectedIcon == icon;

                  return Tooltip(
                    message: tooltip,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedIcon = icon);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _selectedColor.withValues(alpha: 0.22)
                              : (isDark ? StashColors.raised : theme.colorScheme.surfaceContainerHigh),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? _selectedColor
                                : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Icon(
                          icon,
                          size: 22,
                          color: isSelected ? _selectedColor : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: Spacing.md),

            // Color Picker
            Text(
              'ACCENT COLOR',
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _kGoalColors.length,
                separatorBuilder: (_, _) => const SizedBox(width: Spacing.sm),
                itemBuilder: (ctx, i) {
                  final color = _kGoalColors[i];
                  final isSelected = _selectedColor == color;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedColor = color);
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 2.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              size: 18,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: Spacing.xl),

            // Submit Button
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _saveGoal,
              child: Text(
                isEditing ? 'Update Goal' : 'Create Savings Goal',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
            const SizedBox(height: Spacing.md),
          ],
        ),
      ),
    );
  }
}
