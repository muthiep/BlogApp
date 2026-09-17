// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:blog_mobile/Auth/session.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await Session.clear();
  });

  test('login session stays active when remember me is off', () async {
    await Session.save(
      token: 'abc123',
      idUser: 7,
      nameUser: 'Dewi',
      email: 'dewi@test.com',
      rememberMe: false,
    );

    expect(Session.token, 'abc123');
    expect(Session.idUser, 7);
    expect(Session.isLoggedIn, isTrue);
  });

  test('remember me stores session in preferences', () async {
    await Session.save(
      token: 'saved-token',
      idUser: 11,
      nameUser: 'Budi',
      email: 'budi@test.com',
      rememberMe: true,
    );

    final prefs = await SharedPreferences.getInstance();

    expect(prefs.getString('token'), 'saved-token');
    expect(prefs.getString('nameUser'), 'Budi');
  });
}
