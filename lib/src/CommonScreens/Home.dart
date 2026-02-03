import 'package:cfs_app/src/Stuffing/screens/stuffing_screen.dart';
import 'package:cfs_app/src/constants/theme.dart';
import 'package:cfs_app/src/login/loginController.dart';
import 'package:cfs_app/src/Destuffing/screens/destuffing_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Dummy screen imports (replace with your actual screen imports)

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(),
    const SettingsScreen(),
    const BackScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text(
          "CFS App",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, Colors.deepOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Get.find<LoginController>().logout();
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          elevation: 10,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Settings",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.arrow_back),
              label: "Back",
            ),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Color(0xFFFFEBEE)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: const [
            SizedBox(height: 30),
            HomeCard(
              title: "STUFFING",
              type: "LCL",
              icon: Icons.inventory_2_outlined,
              color1: Colors.pinkAccent,
              color2: Colors.deepOrange,
            ),
            SizedBox(height: 20),
            HomeCard(
              title: "DESTUFFING",
              type: "LCL EXPORT",
              icon: Icons.local_shipping_outlined,
              color1: Colors.teal,
              color2: Colors.green,
            ),
            SizedBox(height: 20),
            HomeCard(
              title: "Cargo Receiving",
              type: "RECEIVING",
              icon: Icons.cloud_download_outlined,
              color1: Colors.blueAccent,
              color2: Colors.indigo,
            ),
            SizedBox(height: 20),
            HomeCard(
              title: "Cargo Delivery",
              type: "DELIVERY",
              icon: Icons.cloud_upload_outlined,
              color1: Colors.purpleAccent,
              color2: Colors.deepPurple,
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class HomeCard extends StatelessWidget {
  final String title;
  final String type;
  final IconData icon;
  final Color color1;
  final Color color2;

  const HomeCard({
    super.key,
    required this.title,
    required this.type,
    required this.icon,
    required this.color1,
    required this.color2,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (title == "STUFFING") {
          Get.to(() => StuffingScreen(type: type));
        } else if (title == "DESTUFFING") {
          Get.to(() => DestuffingScreen(type: type));
        } else if (title == "Cargo Receiving") {
          Get.to(() => ());
        } else if (title == "Cargo Delivery") {
          Get.to(() => ());
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        shadowColor: color1.withOpacity(0.5),
        child: Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [color1, color2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 20),
              Icon(icon, color: Colors.white, size: 48),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "⚙️ Settings Page (Coming Soon)",
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}

class BackScreen extends StatelessWidget {
  const BackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
