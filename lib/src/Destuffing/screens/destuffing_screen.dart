import 'dart:async';
import 'package:cfs_app/src/Destuffing/models/ContainerModel.dart';
import 'package:cfs_app/src/constants/theme.dart';
import 'package:cfs_app/src/forms/customBottomNav.dart';
import 'package:cfs_app/src/Destuffing/controller/destuffingController.dart';
import 'package:cfs_app/src/Destuffing/screens/packages_screen.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DestuffingScreen extends StatefulWidget {
  final String type;

  const DestuffingScreen({super.key, required this.type});

  @override
  State<DestuffingScreen> createState() => _DestuffingScreenState();
}

class _DestuffingScreenState extends State<DestuffingScreen> {
  final DestuffingController ctrl = Get.put(DestuffingController());
  int _currentIndex = 0;
  final TextEditingController searchCtrl = TextEditingController();
  var filteredContainers = <ContainerModel>[].obs;

  @override
  void initState() {
    super.initState();
    ctrl.fetchContainers();
    filteredContainers.assignAll(ctrl.containers); // initially all
    // Update filtered list whenever main list changes
    ever(ctrl.containers, (_) => filterContainers(searchCtrl.text));
  }

  void filterContainers(String query) {
    if (query.isEmpty) {
      filteredContainers.assignAll(ctrl.containers);
    } else {
      filteredContainers.assignAll(
        ctrl.containers.where(
          (c) =>
              (c.containerNumber?.toLowerCase() ?? "").contains(
                query.toLowerCase(),
              ) ||
              (c.sealNumber?.toLowerCase() ?? "").contains(
                query.toLowerCase(),
              ) ||
              (c.customerStatus?.toLowerCase() ?? "").contains(
                query.toLowerCase(),
              ),
        ),
      );
    }
  }

  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds % 60)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          "Destuffing",
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchCtrl,
              onChanged: filterContainers,
              decoration: InputDecoration(
                hintText: "Search containers...",
                fillColor: Colors.white,
                filled: true,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (filteredContainers.isEmpty) {
          return const Center(child: Text("No containers found"));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(0),
          itemCount: filteredContainers.length,
          separatorBuilder:
              (_, __) => const Divider(height: 1, color: Colors.grey),
          itemBuilder: (context, index) {
            final cargo = filteredContainers[index];

            return GestureDetector(
              onLongPress: () {
                setState(() {
                  if (!cargo.isRunning) {
                    // start timer locally
                    cargo.isRunning = true;
                    cargo.elapsed = Duration.zero;
                    cargo.timer = Timer.periodic(const Duration(seconds: 1), (
                      _,
                    ) {
                      setState(() {
                        cargo.elapsed += const Duration(seconds: 1);
                      });
                    });

                    // 🔥 Call Odoo "start"
                    ctrl.updateDestuffStatus(cargo.id, "start");
                  } else {
                    // stop & reset locally
                    cargo.isRunning = false;
                    cargo.timer?.cancel();
                    cargo.elapsed = Duration.zero;

                    // 🔥 Call Odoo "stop"
                    ctrl.updateDestuffStatus(cargo.id, "stop");
                  }
                });
              },

              child: ListTile(
                tileColor:
                    cargo.isRunning
                        ? Colors.green.withOpacity(0.5) // ✅ indication
                        : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: Text(
                  "Container: ${cargo.containerNumber ?? "-"}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Seal No: ${cargo.sealNumber ?? "-"}"),
                    Text(
                      "Customer Status: ${cargo.customerStatus ?? "To be assigned"}",
                    ),
                    Text("POL: ${cargo.origin ?? "-"}"),
                    if (cargo.isRunning || cargo.elapsed.inSeconds > 0)
                      Text("⏱ ${formatDuration(cargo.elapsed)}"),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PackagesScreen(destuffId: cargo.id),
                    ),
                  );
                },
              ),
            );
          },
        );
      }),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
