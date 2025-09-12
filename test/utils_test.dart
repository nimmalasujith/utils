import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utils/utils.dart'; // your library

void main() {
  testWidgets('buildTextFieldContainer shows hint and responds to input',
          (WidgetTester tester) async {
        final controller = TextEditingController();
        String changedValue = '';

        // Build the widget inside a MaterialApp (needed for TextField)
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: buildTextFieldContainer(
                controller: controller,
                hintText: "Enter name",
                labelText: "Name",
                onChanged: (val) => changedValue = val,
              ),
            ),
          ),
        );

        // Verify hint text is present
        expect(find.text("Enter name"), findsOneWidget);

        // Enter some text
        await tester.enterText(find.byType(TextField), "Flutter");
        await tester.pump();

        // Verify text was entered
        expect(controller.text, "Flutter");

        // Verify onChanged callback was triggered
        expect(changedValue, "Flutter");
      });
}