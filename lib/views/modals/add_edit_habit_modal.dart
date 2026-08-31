import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../models/habit.dart';
import '../../models/habit_category.dart';
import '../../providers/habit_provider.dart';
import '../widgets/bounce_button.dart';

class AddEditHabitModal extends StatefulWidget {
  final Habit? habit; // If not null, edit mode

  const AddEditHabitModal({super.key, this.habit});

  static Future<void> show(BuildContext context, {Habit? habit}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEditHabitModal(habit: habit),
    );
  }

  @override
  State<AddEditHabitModal> createState() => _AddEditHabitModalState();
}

class _AddEditHabitModalState extends State<AddEditHabitModal> {
  late TextEditingController _nameController;
  late String _selectedCategory;
  late String _selectedIcon;
  late Color _selectedColor;
  late String _selectedFrequency;
  late List<int> _scheduledDays;
  int _targetDays = 7;

  final List<String> _frequencies = ['Daily', 'Weekdays', 'Weekends', 'Custom'];
  final List<({int day, String label, String full})> _weekdays = const [
    (day: 1, label: 'M', full: 'Mon'),
    (day: 2, label: 'T', full: 'Tue'),
    (day: 3, label: 'W', full: 'Wed'),
    (day: 4, label: 'T', full: 'Thu'),
    (day: 5, label: 'F', full: 'Fri'),
    (day: 6, label: 'S', full: 'Sat'),
    (day: 7, label: 'S', full: 'Sun'),
  ];

  @override
  void initState() {
    super.initState();
    final h = widget.habit;
    _nameController = TextEditingController(text: h?.name ?? '');
    _selectedCategory = h?.category ?? 'Morning';
    _selectedIcon = h?.icon ?? 'flame';
    _selectedColor = h != null ? AppColors.fromHex(h.color) : AppColors.habitPalette.first;
    _selectedFrequency = h?.frequency ?? 'Daily';
    _scheduledDays = List.from(h?.scheduledDays ?? [1, 2, 3, 4, 5, 6, 7]);
    _targetDays = h?.targetDays ?? 7;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onFrequencyChanged(String freq) {
    setState(() {
      _selectedFrequency = freq;
      if (freq == 'Daily') {
        _scheduledDays = [1, 2, 3, 4, 5, 6, 7];
      } else if (freq == 'Weekdays') {
        _scheduledDays = [1, 2, 3, 4, 5];
      } else if (freq == 'Weekends') {
        _scheduledDays = [6, 7];
      }
    });
  }

  void _toggleScheduledDay(int day) {
    setState(() {
      if (_scheduledDays.contains(day)) {
        if (_scheduledDays.length > 1) {
          _scheduledDays.remove(day);
        }
      } else {
        _scheduledDays.add(day);
        _scheduledDays.sort();
      }
      _selectedFrequency = 'Custom';
    });
  }

  void _saveHabit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final habitProvider = Provider.of<HabitProvider>(context, listen: false);

    if (widget.habit == null) {
      // Create
      final newHabit = Habit(
        name: name,
        icon: _selectedIcon,
        color: AppColors.toHex(_selectedColor),
        category: _selectedCategory,
        frequency: _selectedFrequency,
        scheduledDays: _scheduledDays,
        targetDays: _targetDays,
      );
      habitProvider.addHabit(newHabit);
    } else {
      // Update
      final updatedHabit = widget.habit!.copyWith(
        name: name,
        icon: _selectedIcon,
        color: AppColors.toHex(_selectedColor),
        category: _selectedCategory,
        frequency: _selectedFrequency,
        scheduledDays: _scheduledDays,
        targetDays: _targetDays,
      );
      habitProvider.updateHabit(updatedHabit);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEdit = widget.habit != null;

    final categories = HabitCategory.defaultCategories
        .where((c) => c.name != 'All')
        .toList();

    final iconKeys = AppIcons.habitIconMap.keys.toList();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modal grab handle
            Center(
              child: Container(
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF333B4F) : const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEdit ? 'Edit Routine' : 'New Habit',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.xmark_circle_fill),
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Habit Name Input
            Text(
              'NAME',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2230) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF2D3348) : const Color(0xFFE2E8F0),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _nameController,
                autofocus: !isEdit,
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                decoration: const InputDecoration(
                  hintText: 'e.g., Morning Meditation, 2L Water...',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Category Picker
            Text(
              'CATEGORY',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = _selectedCategory == cat.name;
                  return BounceButton(
                    onTap: () => setState(() => _selectedCategory = cat.name),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? cat.color.withValues(alpha: isDark ? 0.3 : 0.15)
                            : (isDark ? const Color(0xFF1E2230) : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? cat.color : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(cat.icon, size: 14, color: isSelected ? cat.color : null),
                          const SizedBox(width: 6),
                          Text(
                            cat.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? cat.color : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Frequency Picker
            Text(
              'FREQUENCY',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: CupertinoSlidingSegmentedControl<String>(
                groupValue: _selectedFrequency,
                children: {
                  for (final f in _frequencies)
                    f: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      child: Text(
                        f,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _selectedFrequency == f
                              ? (isDark ? Colors.white : Colors.black)
                              : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                        ),
                      ),
                    ),
                },
                onValueChanged: (val) {
                  if (val != null) _onFrequencyChanged(val);
                },
              ),
            ),
            const SizedBox(height: 12),

            // 7-Day Weekday Pills Selector
            Text(
              'ACTIVE DAYS',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _weekdays.map((w) {
                final isSelected = _scheduledDays.contains(w.day);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.5),
                    child: BounceButton(
                      onTap: () => _toggleScheduledDay(w.day),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _selectedColor
                              : (isDark ? const Color(0xFF1E2230) : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? _selectedColor
                                : (isDark ? const Color(0xFF2D3348) : const Color(0xFFE2E8F0)),
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: _selectedColor.withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            w.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Icon Picker
            Text(
              'ICON',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: iconKeys.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final key = iconKeys[index];
                  final icon = AppIcons.habitIconMap[key]!;
                  final isSelected = _selectedIcon == key;
                  return BounceButton(
                    onTap: () => setState(() => _selectedIcon = key),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _selectedColor.withValues(alpha: isDark ? 0.3 : 0.15)
                            : (isDark ? const Color(0xFF1E2230) : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? _selectedColor : Colors.transparent,
                          width: 2.0,
                        ),
                      ),
                      child: Icon(
                        icon,
                        size: 22,
                        color: isSelected ? _selectedColor : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Color Palette
            Text(
              'COLOR THEME',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: AppColors.habitPalette.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final color = AppColors.habitPalette[index];
                  final isSelected = _selectedColor.toARGB32() == color.toARGB32();
                  return BounceButton(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.5),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(CupertinoIcons.checkmark, color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),

            // Save Button
            BounceButton(
              onTap: _saveHabit,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_selectedColor, _selectedColor.withValues(alpha: 0.8)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: _selectedColor.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    isEdit ? 'Update Routine' : 'Create Routine',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
