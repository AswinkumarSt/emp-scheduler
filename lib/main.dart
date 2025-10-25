import 'package:employee_scheduler/core/services/supabase_service.dart';
import 'package:employee_scheduler/features/auth/presentation/pages/onboarding_page.dart';
import 'package:employee_scheduler/features/task/domain/cubit/task_cubit.dart';
import 'package:employee_scheduler/features/task/domain/repository/task_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseService().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Provide TaskCubit globally
        BlocProvider(
          create: (context) => TaskCubit(
            taskRepository: TaskRepository(
              supabase: Supabase.instance.client,
            ),
          ),
        ),
        // Add other cubits/blocs here as needed
      ],
      child: MaterialApp(
        title: 'Team Scheduler',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const OnboardingPage(),
      ),
    );
  }
}