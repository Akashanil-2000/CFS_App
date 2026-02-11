import 'package:cfs_app/src/Destuffing/models/ContainerModel.dart';
import 'package:cfs_app/src/Destuffing/screens/destuffing/destuffing_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class ContainerList extends StatelessWidget {
  final List<ContainerModel> list;

  const ContainerList(this.list, {super.key});

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) {
      return const Center(child: Text("No Containers"));
    }

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (_, i) {
        final c = list[i];
        return ListTile(
          title: Text(c.containerNumber ?? "-"),
          subtitle: Text(c.state ?? "-"),
          onTap: () {
            Get.to(() => DestuffingScreen(type: "LCL"));
          },
        );
      },
    );
  }
}
