import 'package:flutter/material.dart';
import 'package:stichanda_driver/view/base/custom_app_bar.dart';

class UpdateProfileScreen extends StatelessWidget {
  const UpdateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Update Profile'),
      body: Center(child: Text('Update Profile Screen')),
    );
  }
}
