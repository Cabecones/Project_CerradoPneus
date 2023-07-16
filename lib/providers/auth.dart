import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/data/store.dart';
import 'package:shop/exceptions/auth_exception.dart';

class Auth with ChangeNotifier {
  late String _userId;
  late String _token;
  late DateTime _expiryDate;
  late Timer _logoutTimer;

  bool get isAuth {
    return token != null;
  }

  String? get userId {
    return isAuth ? _userId : null;
  }

  String? get token {
    if (_token != null &&
        _expiryDate != null &&
        _expiryDate.isAfter(DateTime.now())) {
      return _token;
    } else {
      return null;
    }
  }

  Future<void> _authenticate(
      String email,
      String password,
      String urlSegment, {
        String? firstName,
        String? lastName,
        int? age,
      }) async {
    final url =
        'https://dummyjson.com/auth/$urlSegment';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "username": email,
        "password": password,
        "firstName": firstName,
        "lastName": lastName,
        "age": age,
      }),
    );

    final responseBody = json.decode(response.body);
    if (responseBody["error"] != null) {
      throw AuthException(responseBody['error']['message']);
    } else {
      _token = responseBody["token"];
      _userId = responseBody["userId"];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseBody["expiresIn"]),
        ),
      );

      _autoLogout();
      notifyListeners();
      // Save user data locally using Store (or any other storage mechanism you prefer)
      await Store.setMap('userData', {
        "token": _token,
        "userId": _userId,
        "expiryDate": _expiryDate.toIso8601String(),
      }
      );
    }
  }

  Future<void> signup(
      String email,
      String password,
      String firstName,
      String lastName,
      int age,
      ) async {
    return _authenticate(
      email,
      password,
      "signup",
      firstName: firstName,
      lastName: lastName,
      age: age,
    );
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, "login");
  }

  Future<void> tryAutoLogin() async {
    if (isAuth) {
      return Future.value();
    }

    final userData = await Store.getMap('userData');
    if (userData == null) {
      return Future.value();
    }

    final expiryDate = DateTime.parse(userData["expiryDate"]);

    if (expiryDate.isBefore(DateTime.now())) {
      return Future.value();
    }

    _userId = userData["userId"];
    _token = userData["token"];
    _expiryDate = expiryDate;

    _autoLogout();
    notifyListeners();
    return Future.value();
  }

  Future<void> logout() async {
    _userId = "";
    _token = "";
    _expiryDate = DateTime.now();
    _logoutTimer.cancel();
    notifyListeners();
    await Store.remove('userData');
  }

  void _autoLogout() {
    if (_logoutTimer != null) {
      _logoutTimer.cancel();
    }
    final timeToLogout = _expiryDate.difference(DateTime.now()).inSeconds;
    _logoutTimer = Timer(Duration(seconds: timeToLogout), logout);
  }
}
