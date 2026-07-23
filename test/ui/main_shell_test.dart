import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/app.dart';
import 'package:keuangan_app/auth/auth_service.dart';

class FakeAuthService implements AuthService {
  @override
  Future<String?> currentToken() async => null;
  @override
  Stream<bool> authChanges() => const Stream.empty();
  @override
  String? get displayName => 'Test';
  @override
  Future<void> signInWithGoogle() async {}
  @override
  Future<void> signOut() async {}
}

void main() {
  testWidgets('boots to the splash screen without throwing', (tester) async {
    await tester.pumpWidget(KeuanganApp(authService: FakeAuthService()));
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
  });
}
