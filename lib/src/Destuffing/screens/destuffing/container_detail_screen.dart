import 'package:cfs_app/src/Destuffing/controller/destuffingController.dart';
import 'package:cfs_app/src/Destuffing/models/container_detail_model.dart';
import 'package:cfs_app/src/Destuffing/widgets/detail_page/detail_header_card.dart';
import 'package:cfs_app/src/Destuffing/widgets/detail_page/detail_info_row.dart';
import 'package:cfs_app/src/Destuffing/widgets/detail_page/detail_section_card.dart';
import 'package:cfs_app/src/Destuffing/widgets/detail_page/status_formatter.dart';
import 'package:cfs_app/src/constants/theme.dart';
import 'package:cfs_app/src/forms/customBottomNav.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ContainerDetailScreen extends StatefulWidget {
  final int id;
  const ContainerDetailScreen({super.key, required this.id});

  @override
  State<ContainerDetailScreen> createState() => _ContainerDetailScreenState();
}

class _ContainerDetailScreenState extends State<ContainerDetailScreen> {
  final ctrl = Get.find<DestuffingController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctrl.fetchContainerDetail(widget.id);
    });
  }

  int _currentIndex = 0;
  bool canSchedule(ContainerDetailModel d) {
    return (d.customStatus ?? "").toLowerCase() == "cleared" &&
        (d.paymentStatus ?? "").toLowerCase() == "completed";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          "Container Details",
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
        if (ctrl.isLoading.value || ctrl.detail.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final d = ctrl.detail.value!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// HEADER
              DetailHeaderCard(
                title: d.name ?? "-",
                customsStatus: formatCustomStatus(d.customStatus),
                paymentStatus: formatPaymentStatus(d.paymentStatus),
              ),

              const SizedBox(height: 16),

              /// SHIPPING INFO
              DetailSectionCard(
                title: "Shipping Info",
                children: [
                  DetailInfoRow(
                    label: "Container Type",
                    value: d.containerType,
                  ),
                  DetailInfoRow(
                    label: "Container No",
                    value: d.containerNumber,
                  ),
                  DetailInfoRow(label: "Seal No", value: d.sealNumber),
                  DetailInfoRow(label: "Request Date", value: d.requestDate),
                  DetailInfoRow(label: "Priority", value: d.priority),
                  DetailInfoRow(
                    label: "Priority Remarks",
                    value: d.priorityRemarks,
                  ),
                ],
              ),

              /// LOCATION INFO
              DetailSectionCard(
                title: "Location Info",
                children: [
                  DetailInfoRow(label: "POL Country", value: d.originCountry),
                  DetailInfoRow(label: "POL", value: d.origin),
                ],
              ),

              /// CARGO DETAILS
              DetailSectionCard(
                title: "Cargo Details",
                children: [
                  DetailInfoRow(
                    label: "HBL Count",
                    value: d.hblCount?.toString(),
                  ),
                  DetailInfoRow(label: "Packages UOM", value: d.packagesUom),
                  DetailInfoRow(label: "Weight UOM", value: d.weightUom),
                  DetailInfoRow(label: "Volume UOM", value: d.volumeUom),
                ],
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        final d = ctrl.detail.value;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// SCHEDULE BUTTON
            if (d != null && canSchedule(d))
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () {
                      Get.snackbar(
                        "Schedule",
                        "Ready to schedule container",
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    child: const Text(
                      "Schedule",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

            /// COMMON BOTTOM NAV
            CustomBottomNav(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
            ),
          ],
        );
      }),
    );
  }
}
