import 'package:cfs_app/src/login/loginController.dart';
import 'package:cfs_app/src/login/loginScreen.dart';
import 'package:cfs_app/src/CommonScreens/Home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init(); // 🔑 initialize storage

  final box = GetStorage();
  final isLoggedIn = box.read('isLoggedIn') ?? false;
  Get.put(LoginController());

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CFS App',
      home: isLoggedIn ? const HomeScreen() : LoginScreen(),
    );
  }
}
