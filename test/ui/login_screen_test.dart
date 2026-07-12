import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:keuangan_app/auth/auth_bloc.dart';
import 'package:keuangan_app/auth/auth_event.dart';
import 'package:keuangan_app/auth/auth_state.dart';
import 'package:keuangan_app/ui/login_screen.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  setUpAll(() {
    registerFallbackValue(AuthSignInRequested());
  });

  testWidgets('tapping Google button dispatches AuthSignInRequested', (tester) async {
    final auth = MockAuthBloc();
    when(() => auth.state).thenReturn(const AuthState.unauthenticated());

    await tester.pumpWidget(MaterialApp(
      home: BlocProvider<AuthBloc>.value(value: auth, child: const LoginScreen()),
    ));

    await tester.tap(find.byKey(const Key('google-signin')));
    verify(() => auth.add(any(that: isA<AuthSignInRequested>()))).called(1);
  });
}
