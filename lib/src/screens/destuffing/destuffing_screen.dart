import 'package:cfs_app/src/constants/theme.dart';
import 'package:cfs_app/src/screens/destuffing/destuffingController.dart';
import 'package:cfs_app/src/screens/package/packages_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DestuffingScreen extends StatelessWidget {
  final String type; // LCL or FCL
  final DestuffingController ctrl = Get.put(DestuffingController());

  DestuffingScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    ctrl.fetchContainers(); // call API on load

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Destuffing", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (ctrl.containers.isEmpty) {
          return const Center(child: Text("No containers found"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ctrl.containers.length,
          itemBuilder: (context, index) {
            final cargo = ctrl.containers[index];
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => PackagesScreen(
                          destuffId: cargo.id, // ✅ pass containerId
                        ),
                  ),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Container: ${cargo.containerNumber ?? "-"}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text("Seal No: ${cargo.sealNumber ?? "-"}"),
                      Text(
                        "Customer Status: ${cargo.customerStatus ?? "To be assigned"}",
                        style: TextStyle(
                          color:
                              cargo.customerStatus == null
                                  ? Colors.red
                                  : Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      Text("POL: ${cargo.origin ?? "-"}"),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
