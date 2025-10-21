import 'package:cfs_app/src/constants/theme.dart';
import 'package:cfs_app/src/forms/customBottomNav.dart';
import 'package:cfs_app/src/Destuffing/models/packageModel.dart';
import 'package:cfs_app/src/Destuffing/screens/addPackageScreen.dart';
import 'package:cfs_app/src/Destuffing/controller/packageController.dart';
import 'package:cfs_app/src/Destuffing/screens/packageSubmissionScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PackagesScreen extends StatefulWidget {
  final int destuffId;

  const PackagesScreen({super.key, required this.destuffId});

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  late final PackagesController ctrl;
  int _currentIndex = 0;
  final TextEditingController searchCtrl = TextEditingController();
  var filteredPackages = <PackageModel>[].obs;

  @override
  void initState() {
    super.initState();
    ctrl = Get.put(
      PackagesController(destuffId: widget.destuffId),
      tag: widget.destuffId.toString(),
    );
    filteredPackages.assignAll(ctrl.packages);
    ever(ctrl.packages, (_) => filterPackages(searchCtrl.text));
  }

  void filterPackages(String query) {
    if (query.isEmpty) {
      filteredPackages.assignAll(ctrl.packages);
    } else {
      filteredPackages.assignAll(
        ctrl.packages.where(
          (p) =>
              (p.hblNo.toLowerCase()).contains(query.toLowerCase()) ||
              (p.commodity.toLowerCase()).contains(query.toLowerCase()) ||
              (p.status.toLowerCase()).contains(query.toLowerCase()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          "Packages",
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
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == "submit") {
                Get.to(() => PackagesSubmitScreen(controller: ctrl));
              } else if (value == "print") {
                ctrl.printPackages();
              }
            },
            itemBuilder:
                (context) => const [
                  PopupMenuItem(value: "submit", child: Text("Submit")),
                  PopupMenuItem(value: "print", child: Text("Print")),
                ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchCtrl,
              onChanged: filterPackages,
              decoration: InputDecoration(
                hintText: "Search packages...",
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
        if (ctrl.isLoading.value)
          return const Center(child: CircularProgressIndicator());
        if (filteredPackages.isEmpty)
          return const Center(child: Text("No packages found"));

        return ListView.separated(
          padding: const EdgeInsets.all(0),
          itemCount: filteredPackages.length,
          separatorBuilder:
              (_, __) => const Divider(height: 1, color: Colors.grey),
          itemBuilder: (context, index) {
            final pkg = filteredPackages[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              title: Text(
                "HBL No: ${pkg.hblNo}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Commodity: ${pkg.commodity}"),
                  Text("Status: ${pkg.status}"),
                  Text("Packages: ${pkg.packages}"),
                ],
              ),
              onTap:
                  () => Get.to(
                    () => AddPackageScreen(hblNo: pkg.hblNo, controller: ctrl),
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
