import 'package:employee_scheduler/core/services/supabase_service.dart';
import 'package:employee_scheduler/features/auth/presentation/widgets/auth_field.dart';
import 'package:employee_scheduler/features/auth/presentation/widgets/auth_gradient_button.dart';
import 'package:employee_scheduler/features/auth/presentation/widgets/profile_photo_upload.dart';
import 'package:employee_scheduler/features/availability/presentation/pages/availability_page.dart';
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
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _initializeSupabase();
  }

  Future<void> _initializeSupabase() async {
    await _supabaseService.initialize();
  }

  void _onPhotoSelected(XFile? photo) {
    setState(() {
      _selectedPhoto = photo;
    });
  }

  Future<void> _handleContinue() async {
    final name = _nameController.text.trim();
    
    if (name.isEmpty) {
      _showErrorSnackBar('Please enter your name');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? photoUrl;

      if (_selectedPhoto != null) {
        photoUrl = await _supabaseService.uploadProfileImage(_selectedPhoto!);
        if (photoUrl == null) {
          _showErrorSnackBar('Failed to upload profile photo');
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      final userData = await _supabaseService.saveUser(name, photoUrl);
      
      if (userData != null) {
        _showSuccessSnackBar('Welcome, $name!');
        
        print('User created:');
        print('ID: ${userData['id']}');
        print('Name: ${userData['name']}');
        print('Photo: ${userData['photo_url']}');
        
        // Navigate to availability page after a short delay
        Future.delayed(const Duration(milliseconds: 1500), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AvailabilityPage(userId: userData['id']),
            ),
          );
        });
        
      } else {
        _showErrorSnackBar('Failed to create user');
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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