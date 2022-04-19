import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:ubuntu_wizard/widgets.dart';
import 'package:ubuntu_wsl_setup/l10n.dart';
import 'package:ubuntu_wsl_setup/pages.dart';
import 'package:ubuntu_wsl_setup/pages/applying_changes/applying_changes_model.dart';

import 'applying_changes_page_test.mocks.dart';
import 'test_utils.dart';

@GenerateMocks([ApplyingChangesModel])
void main() {
  const theEnd = 'The end';
  LangTester.type = ApplyingChangesModel;

  Widget buildPage(ApplyingChangesModel model) {
    return ChangeNotifierProvider<ApplyingChangesModel>.value(
      value: model,
      child: ApplyingChangesPage(),
    );
  }

  Widget buildApp(ApplyingChangesModel model) {
    return MaterialApp(
      localizationsDelegates: localizationsDelegates,
      home: Wizard(
        routes: {
          '/': WizardRoute(
            builder: (_) => buildPage(model),
            onNext: (settings) => '/end',
          ),
          '/end': WizardRoute(
            builder: (_) => Center(
              child: const Text(theEnd),
            ),
            onNext: (settings) => '/end',
          ),
        },
      ),
    );
  }

  testWidgets('goes to the next page on false', (tester) async {
    final model = MockApplyingChangesModel();
    when(model.init(onDoneTransition: captureAnyNamed('onDoneTransition')))
        .thenAnswer((realInvocation) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        realInvocation.namedArguments[Symbol('onDoneTransition')]();
      });
    });
    await tester.pumpWidget(buildApp(model));
    expect(find.text(theEnd), findsNothing);
    await tester.pumpAndSettle();
    expect(find.text(theEnd), findsOneWidget);
  });

  testWidgets('won\'t go next while still installing', (tester) async {
    final model = MockApplyingChangesModel();
    when(model.init(onDoneTransition: captureAnyNamed('onDoneTransition')))
        .thenAnswer((realInvocation) {});
    await tester.pumpWidget(buildApp(model));
    expect(find.text(theEnd), findsNothing);
    await tester.pump(Duration.zero);
    expect(find.text(theEnd), findsNothing);
    await tester.pump(Duration.zero);
    expect(find.text(theEnd), findsNothing);
  });
}