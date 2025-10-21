import 'dart:convert';
import 'package:cfs_app/src/login/loginScreen.dart';
import 'package:cfs_app/src/CommonScreens/Home.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class LoginController extends GetxController {
  final String url = "https://css.odoouae.org/jsonrpc";
  final String db = "css_dmp_mar_25";

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  final box = GetStorage();

  Future<void> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      errorMessage("Please enter username and password");
      return;
    }

    try {
      isLoading(true);
      errorMessage('');

      final body = {
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
          "service": "common",
          "method": "login",
          "args": [db, username, password],
        },
        "id": 1,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      print(data);

      if (data["result"] != null && data["result"] is int) {
        // ✅ Success: userId returned
        final userId = data["result"];

        debugPrint("✅ Logged in successfully. User ID: $userId");

        box.write('isLoggedIn', true);
        box.write('username', username);
        box.write('password', password);
        box.write('userId', userId);

        Get.offAll(() => const HomeScreen());
      } else {
        errorMessage("Invalid username or password");
      }
    } catch (e) {
      errorMessage("Login failed. Please try again.");
    } finally {
      isLoading(false);
    }
  }

  Future<void> autoLogin() async {
    final username = box.read('username');
    final password = box.read('password');
    if (username != null && password != null) {
      await login(username, password);
    }
  }

  void logout() {
    box.erase();
    Get.offAll(() => LoginScreen());
  }
}
