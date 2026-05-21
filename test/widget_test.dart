import 'package:flutter_test/flutter_test.dart';
import 'package:honset_app/core/di/injection.dart';
import 'package:honset_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:honset_app/main.dart';

void main() {
  testWidgets('Honset app opens the login flow', (tester) async {
    await configureDependencies();
    await tester.pumpWidget(HonsetApp(authCubit: getIt<AuthCubit>()));
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
  });
}
