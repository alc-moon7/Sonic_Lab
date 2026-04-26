import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sonic_lab/core/widgets/glow_circle_button.dart';
import 'package:sonic_lab/core/widgets/segmented_picker.dart';
import 'package:sonic_lab/core/widgets/sonic_bottom_nav_bar.dart';

void main() {
  testWidgets('GlowCircleButton renders label and handles tap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GlowCircleButton(
            variant: GlowCircleVariant.water,
            icon: Icons.water_drop,
            label: 'Clean Water',
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Clean Water'), findsOneWidget);
    await tester.tap(find.byType(GlowCircleButton));
    expect(tapped, isTrue);
  });

  testWidgets('SegmentedPicker selects a value', (tester) async {
    var selected = 15;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SegmentedPicker(
            values: const [15, 30, 60],
            selectedValue: selected,
            onChanged: (value) => selected = value,
          ),
        ),
      ),
    );

    await tester.tap(find.text('60s'));
    expect(selected, 60);
  });

  testWidgets('SonicBottomNavBar shows active label', (tester) async {
    var selected = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: SonicBottomNavBar(
            activeIndex: 1,
            onSelected: (index) => selected = index,
          ),
        ),
      ),
    );

    expect(find.text('DUST'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.settings));
    expect(selected, 3);
  });
}
