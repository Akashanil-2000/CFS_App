import 'package:cfs_app/src/Destuffing/controller/destuffingController.dart';
import 'package:cfs_app/src/Destuffing/models/ContainerModel.dart';
import 'package:cfs_app/src/Destuffing/screens/destuffing/destuffing_screen.dart';
import 'package:cfs_app/src/constants/theme.dart';
import 'package:cfs_app/src/forms/customBottomNav.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DestuffingDashboardScreen extends StatefulWidget {
  const DestuffingDashboardScreen({super.key});

  @override
  State<DestuffingDashboardScreen> createState() =>
      _DestuffingDashboardScreenState();
}

class _DestuffingDashboardScreenState extends State<DestuffingDashboardScreen> {
  final DestuffingController ctrl = Get.put(DestuffingController());
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    ctrl.fetchContainers();
  }

  List<ContainerModel> filter(List<String> states) {
    return ctrl.containers.where((c) {
      final s = (c.state ?? "").toLowerCase();
      return states.any((st) => s.contains(st));
    }).toList();
  }

  Widget statusCard(
    String title,
    List<String> states,
    Color c1,
    Color c2,
    IconData icon,
  ) {
    final list = filter(states);

    return GestureDetector(
      onTap: () {
        Get.to(() => DestuffingScreen(type: title, preFiltered: list));
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [c1, c2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: c1.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 34),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Containers",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            Text(
              list.length.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          "Destuffing Dashboard",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),

      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              statusCard(
                "Upcoming",
                ["draft", "schedule", "ready"],
                Colors.orange,
                Colors.deepOrange,
                Icons.schedule,
              ),
              statusCard(
                "Ongoing",
                ["process"],
                Colors.blue,
                Colors.indigo,
                Icons.play_circle_fill,
              ),
              statusCard(
                "Hold",
                ["hold"],
                Colors.red,
                Colors.pink,
                Icons.pause_circle_filled,
              ),
              statusCard(
                "Completed",
                ["complete", "over"],
                Colors.green,
                Colors.teal,
                Icons.check_circle,
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
