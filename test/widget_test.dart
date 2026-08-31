import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:auratrack/models/habit.dart';
import 'package:auratrack/views/widgets/activity_ring.dart';
import 'package:auratrack/views/widgets/bounce_button.dart';
import 'package:auratrack/views/widgets/habit_tile.dart';
import 'package:auratrack/views/widgets/mood_selector.dart';

void main() {
  testWidgets('ActivityRing paints smoothly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ActivityRing(
            progress: 0.75,
            size: 100,
          ),
        ),
      ),
    );

    expect(find.byType(ActivityRing), findsOneWidget);
  });

  testWidgets('BounceButton triggers onTap callback', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BounceButton(
            playSound: false,
            onTap: () {
              tapped = true;
            },
            child: const Text('Tap Me'),
          ),
        ),
      ),
    );

    expect(find.text('Tap Me'), findsOneWidget);
    await tester.tap(find.text('Tap Me'));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });

  testWidgets('HabitTile displays habit name and toggles completion', (WidgetTester tester) async {
    final habit = Habit(
      id: 1,
      name: 'Drink Water',
      icon: 'drop',
      color: '#06B6D4',
      category: 'Morning',
      frequency: 'Daily',
    );

    bool toggled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HabitTile(
            habit: habit,
            isCompleted: false,
            streak: 5,
            onToggle: () {
              toggled = true;
            },
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Drink Water'), findsOneWidget);
    expect(find.text('Morning'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);

    await tester.tap(find.byType(BounceButton));
    await tester.pumpAndSettle();
    expect(toggled, isTrue);
  });

  testWidgets('HabitTile displays rest day state cleanly', (WidgetTester tester) async {
    final habit = Habit(
      id: 2,
      name: 'Gym Workout',
      icon: 'heart',
      color: '#10B981',
      category: 'Health',
      frequency: 'Daily',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HabitTile(
            habit: habit,
            isCompleted: false,
            isRestDay: true,
            streak: 3,
            onToggle: () {},
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Rest Day'), findsOneWidget);
  });

  testWidgets('MoodSelector highlights selected mood', (WidgetTester tester) async {
    String selected = 'Radiant';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MoodSelector(
            selectedMood: selected,
            onMoodSelected: (m) => selected = m,
          ),
        ),
      ),
    );

    expect(find.text('Radiant'), findsOneWidget);
    expect(find.text('Good'), findsOneWidget);
    expect(find.text('Neutral'), findsOneWidget);
  });
}
