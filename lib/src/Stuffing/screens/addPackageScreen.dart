import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cfs_app/src/Destuffing/controller/packageController.dart';
import 'package:cfs_app/src/constants/theme.dart';

class AddPackageScreen extends StatefulWidget {
  final String hblNo;
  final PackagesController controller;

  const AddPackageScreen({
    super.key,
    required this.hblNo,
    required this.controller,
  });

  @override
  State<AddPackageScreen> createState() => _AddPackageScreenState();
}

class _AddPackageScreenState extends State<AddPackageScreen> {
  final TextEditingController qtyCtrl = TextEditingController();
  final TextEditingController conditionCtrl = TextEditingController();
  final TextEditingController marksCtrl = TextEditingController();
  final TextEditingController remarksCtrl = TextEditingController();

  List<File> _images = [];
  String? selectedRemark;

  Future<void> _pickImage() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
      );
      if (pickedFile != null) {
        setState(() => _images.add(File(pickedFile.path)));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Camera permission denied")));
    }
  }

  void _save() {
    if (qtyCtrl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter quantity")));
      return;
    }

    final qty = int.tryParse(qtyCtrl.text) ?? 0;
    widget.controller.addPackage(
      widget.hblNo,
      qty,
      condition: conditionCtrl.text,
      marks: marksCtrl.text,
      remarks: selectedRemark ?? "",
      images: _images,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text(
          "Add Package - ${widget.hblNo}",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ), // 🔹 Back button color
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _sectionTitle("Package Details"),
            _buildInputCard(),
            const SizedBox(height: 20),
            _sectionTitle("Photos"),
            _buildImageCard(),
            const SizedBox(height: 30),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      elevation: 2,
      shadowColor: Colors.black12,

      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(
              qtyCtrl,
              "Quantity",
              type: TextInputType.number,
              icon: Icons.numbers,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              conditionCtrl,
              "Condition",
              icon: Icons.inventory_2_outlined,
            ),
            _buildTextField(
              marksCtrl,
              "Marks & Number",
              icon: Icons.qr_code_scanner,
            ),

            _buildRemarksDropdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      elevation: 2,
      shadowColor: Colors.black12,

      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              label: const Text(
                "Add Photo",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_images.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _images[index],
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            iconSize: 18,
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed:
                                () => setState(() => _images.removeAt(index)),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemarksDropdown() {
    return Obx(() {
      final items = widget.controller.remarksList;
      if (items.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return DropdownButtonFormField<String>(
        isExpanded: true,
        value: selectedRemark,
        decoration: InputDecoration(
          labelText: "Remarks",
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),

          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        items:
            items
                .map(
                  (remark) => DropdownMenuItem(
                    value: remark,
                    child: Text(remark, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
        onChanged: (val) => setState(() => selectedRemark = val),
      );
    });
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _save,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: AppColors.primary,
          elevation: 5,
        ),
        child: const Text(
          "Save Package",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType type = TextInputType.text,
    IconData? icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        prefixIcon: icon != null ? Icon(icon, color: AppColors.primary) : null,
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 14,
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }
}
