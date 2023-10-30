import 'package:d_info/d_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_record/config/session.dart';
import 'package:money_record/presentation/page/auth/login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          children: [
            const Text('Home Page'),
            IconButton(
              onPressed: () {
                Session.clearUser();
                DInfo.dialogSuccess('Berhasil Logout');
                DInfo.closeDialog(
                  actionAfterClose: () {
                    Get.off(() => const LoginPage());
                  },
                );
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
      ),
    );
  }
}
