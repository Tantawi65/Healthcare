import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GP Tea')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to GP Tea',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your AI-Powered Health Assistant',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                GoRouter.of(context).go('/symptom_checker');
              },
              child: const Text('Check Symptoms'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                GoRouter.of(context).go('/image_uploader');
              },
              child: const Text('Upload Image'),
            ),
          ],
        ),
      ),
    );
  }
}
