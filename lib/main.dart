import 'package:flutter/material.dart';
import 'package:sooq/core/supabase/supabase_constants.dart';
import 'package:sooq/core/utils/di/get_it.dart';
import 'package:sooq/sooq_app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  setUpGetIt();
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConstants.url,
    anonKey: SupabaseConstants.anonKey,
  );

  runApp(const SooqApp());
}
