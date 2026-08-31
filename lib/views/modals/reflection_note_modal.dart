import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/daily_reflection.dart';
import '../../providers/reflection_provider.dart';
import '../widgets/bounce_button.dart';
import '../widgets/mood_selector.dart';

class ReflectionNoteModal extends StatefulWidget {
  final DateTime date;
  final DailyReflection? existingReflection;

  const ReflectionNoteModal({
    super.key,
    required this.date,
    this.existingReflection,
  });

  static Future<void> show(BuildContext context, {required DateTime date, DailyReflection? existing}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReflectionNoteModal(
        date: date,
        existingReflection: existing,
      ),
    );
  }

  @override
  State<ReflectionNoteModal> createState() => _ReflectionNoteModalState();
}

class _ReflectionNoteModalState extends State<ReflectionNoteModal> {
  late String _selectedMood;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _selectedMood = widget.existingReflection?.mood ?? 'Good';
    _noteController = TextEditingController(text: widget.existingReflection?.note ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    final note = _noteController.text.trim();
    final provider = Provider.of<ReflectionProvider>(context, listen: false);

    provider.saveReflection(
      date: widget.date,
      mood: _selectedMood,
      note: note.isNotEmpty ? note : null,
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateFormatted = DateFormat('EEEE, MMMM d').format(widget.date);

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
            // Grab handle
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Reflection',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateFormatted,
                      style: theme.textTheme.labelSmall?.copyWith(fontSize: 13),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.xmark_circle_fill),
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Mood Selector
            Text(
              'HOW DO YOU FEEL TODAY?',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),
            MoodSelector(
              selectedMood: _selectedMood,
              onMoodSelected: (m) => setState(() => _selectedMood = m),
            ),
            const SizedBox(height: 24),

            // Journal / Notes Input
            Text(
              'THOUGHTS & GRATITUDE (OPTIONAL)',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2230) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? const Color(0xFF2D3348) : const Color(0xFFE2E8F0),
                ),
              ),
              padding: const EdgeInsets.all(14),
              child: TextField(
                controller: _noteController,
                maxLines: null,
                expands: true,
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  fontSize: 15,
                  height: 1.4,
                ),
                decoration: const InputDecoration(
                  hintText: 'What went well today? What did you learn or feel grateful for?',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Save Reflection Button
            BounceButton(
              onTap: _save,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Save Reflection',
                    style: TextStyle(
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
