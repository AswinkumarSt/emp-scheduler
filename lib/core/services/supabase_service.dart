import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  static const String supabaseUrl = 'https://tyrqccnycadsabdwvhzg.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR5cnFjY255Y2Fkc2FiZHd2aHpnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjEyOTUyOTcsImV4cCI6MjA3Njg3MTI5N30.vTI9LeiksuoGVCP6NQ2XJY8mRU-ZDXxcYLrRV1ai1nE';

  final SupabaseClient _client = SupabaseClient(supabaseUrl, supabaseAnonKey);

  SupabaseClient get client => _client;

  Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  Future<String?> uploadProfileImage(XFile imageFile) async {
    try {
      final String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Convert XFile to File
      final File file = File(imageFile.path);
      
      // Upload File to Supabase Storage
      await _client.storage
          .from('profile')
          .upload(fileName, file);

      final String publicUrl = _client.storage
          .from('profile')
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> saveUser(String name, String? photoUrl) async {
    try {
      final response = await _client
          .from('users')
          .insert({
            'name': name,
            'photo_url': photoUrl,
          })
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error saving user: $e');
      return null;
    }
  }

  Future<bool> userExists(String name) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('name', name)
          .single();

      // ignore: unnecessary_null_comparison
      return response != null;
    } catch (e) {
      return false;
    }
  }
}