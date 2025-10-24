import 'package:employee_scheduler/features/auth/presentation/widgets/auth_field.dart';
import 'package:employee_scheduler/features/auth/presentation/widgets/auth_gradient_button.dart';
import 'package:employee_scheduler/features/auth/presentation/widgets/profile_photo_upload.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  XFile? _selectedPhoto;
  
  bool _isLoading = false;
  
  final TextEditingController _nameController = TextEditingController();

  void _onPhotoSelected(XFile? photo) {
    setState(() {
      _selectedPhoto = photo;
    });
  }

  void _handleContinue() {
    final name = _nameController.text.trim();
    
    if (name.isEmpty) {
      _showErrorSnackBar('Please enter your name');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 2)).then((_) {
      setState(() {
        _isLoading = false;
      });

      _showSuccessSnackBar('Welcome, $name!');

      // TODO: Add actual registration logic here
      print('Registration Data:');
      print('Name: $name');
      print('Photo: ${_selectedPhoto?.path}');
      
      // TODO: Navigate to next screen
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Team Scheduler',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            AuthField(
              hintText: 'name',
              controller: _nameController,
            ),
            const SizedBox(height: 30),
            ProfilePhotoUpload(onPhotoSelected: _onPhotoSelected),
            const SizedBox(height: 30),
            AuthGradientButton(
              onPressed: _handleContinue,
              text: 'Continue',
              isLoading: _isLoading,
            ),            
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}