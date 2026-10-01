import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:sooq/core/services/hive/hive_services.dart';
import 'package:sooq/core/services/supabase/supabase_constants.dart';
import 'package:sooq/core/utils/di/get_it.dart';
import 'package:sooq/core/utils/setup_bloc_observer.dart';
import 'package:sooq/features/Home/data/models/product_model.dart';
import 'package:sooq/sooq_app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    Bloc.observer = SetupBlocObserver();
  setUpGetIt();
  await _initHive(); 
  await Supabase.initialize(url: SupabaseConstants.url, anonKey: SupabaseConstants.anonKey);

  runApp(const SooqApp());
}

Future<void> _initHive() async {
  await Hive.initFlutter();
  _registerHiveAdapters();
  await _openHiveBoxes();
}

void _registerHiveAdapters() {
  Hive.registerAdapter((ProductModelAdapter()));
}

Future<void> _openHiveBoxes() async {
  await Future.wait([
    Hive.openBox(HiveService.productsBoxName), // من غير <List<ProductModel>>
  ]);
}
