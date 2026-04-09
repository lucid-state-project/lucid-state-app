import 'package:flutter/widgets.dart';
import 'package:lucid_state_app/app/app.dart';
import 'package:lucid_state_app/core/services/local_storage_service.dart';

void main() async {
  // ── Initialize local storage service global
  // Harus di-call sekali saat app startup sebelum runApp
  WidgetsFlutterBinding.ensureInitialized();
  print('🔄 Initializing LocalStorageService...');
  await LocalStorageService().init();
  print('✅ LocalStorageService initialized');
  
  runApp(const LucidStateApp());
}
