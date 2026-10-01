import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sooq/core/utils/di/get_it.dart';
import 'package:sooq/features/Search/data/repos/search_repo.dart';
import 'package:sooq/features/Search/presentation/cubit/search_cubit.dart';
import 'package:sooq/features/Search/presentation/views/search_view_body.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchCubit(SearchRepository(getIt<SupabaseClient>()))..init(),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: const Scaffold(

          body: SearchViewBody(),
        ),
      ),
    );
  }
}

