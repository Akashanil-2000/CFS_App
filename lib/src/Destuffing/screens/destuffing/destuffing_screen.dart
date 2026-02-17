import 'dart:async';
import 'package:cfs_app/src/Destuffing/models/ContainerModel.dart';
import 'package:cfs_app/src/Destuffing/screens/destuffing/container_detail_screen.dart';
import 'package:cfs_app/src/constants/theme.dart';
import 'package:cfs_app/src/forms/customBottomNav.dart';
import 'package:cfs_app/src/Destuffing/controller/destuffingController.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DestuffingScreen extends StatefulWidget {
  final String type;
  final List<ContainerModel>? preFiltered;

  const DestuffingScreen({super.key, required this.type, this.preFiltered});

  @override
  State<DestuffingScreen> createState() => _DestuffingScreenState();
}

class _DestuffingScreenState extends State<DestuffingScreen> {
  late DestuffingController ctrl;
  int _currentIndex = 0;
  final TextEditingController searchCtrl = TextEditingController();
  var filteredContainers = <ContainerModel>[].obs;

  @override
  void initState() {
    super.initState();

    ctrl = Get.find<DestuffingController>();

    if (widget.preFiltered != null) {
      // Came from Dashboard
      filteredContainers.assignAll(widget.preFiltered!);
    } else {
      // Normal Flow
      ctrl.fetchContainers();
      ever(ctrl.containers, (_) {
        filteredContainers.assignAll(ctrl.containers);
      });
    }
  }

  void filterContainers(String query) {
    final source = widget.preFiltered ?? ctrl.containers;

    if (query.isEmpty) {
      filteredContainers.assignAll(source);
    } else {
      filteredContainers.assignAll(
        source.where(
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
      backgroundColor: AppColors.background,
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

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: filteredContainers.length,
          itemBuilder: (context, index) {
            final cargo = filteredContainers[index];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Container(
                decoration: BoxDecoration(
                  color:
                      cargo.isRunning
                          ? Colors.green.withOpacity(0.08)
                          : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Future.microtask(() {
                      Get.to(() => ContainerDetailScreen(id: cargo.id));
                    });
                  },

                  onLongPress: () {
                    setState(() {
                      if (!cargo.isRunning) {
                        cargo.isRunning = true;
                        cargo.elapsed = Duration.zero;
                        cargo.timer = Timer.periodic(
                          const Duration(seconds: 1),
                          (_) => setState(() {
                            cargo.elapsed += const Duration(seconds: 1);
                          }),
                        );
                        ctrl.updateDestuffStatus(cargo.id, "start");
                      } else {
                        cargo.isRunning = false;
                        cargo.timer?.cancel();
                        cargo.elapsed = Duration.zero;
                        ctrl.updateDestuffStatus(cargo.id, "stop");
                      }
                    });
                  },
                  child: Column(
                    children: [
                      Row(
                        children: [
                          /// LEFT COLOR STRIP
                          Container(
                            width: 6,
                            height: 90,
                            decoration: BoxDecoration(
                              color:
                                  cargo.isRunning
                                      ? Colors.green
                                      : AppColors.primary,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(14),
                                bottomLeft: Radius.circular(14),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          /// CONTENT
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 4,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cargo.containerNumber ?? "-",
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Seal: ${cargo.sealNumber ?? "-"}",
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  Text(
                                    "Status: ${cargo.customerStatus ?? "To be assigned"}",
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  Text(
                                    "POL: ${cargo.origin ?? "-"}",
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  if (cargo.isRunning ||
                                      cargo.elapsed.inSeconds > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        "⏱ ${formatDuration(cargo.elapsed)}",
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),

                          const SizedBox(width: 12),
                        ],
                      ),

                      /// BOTTOM LINE
                      Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        color: Colors.grey.withOpacity(0.2),
                      ),
                    ],
                  ),
                ),
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

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }
}
