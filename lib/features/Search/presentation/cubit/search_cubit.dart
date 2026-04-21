import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sooq/core/utils/ld/pref_helper.dart';
import 'package:sooq/features/Home/data/models/products_model.dart';
import 'package:sooq/features/Search/data/repos/search_repo.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._repository) : super(const SearchState());

  final SearchRepository _repository;

  
  final TextEditingController fieldController = TextEditingController();
  Timer? _debounce;

  // Initialise load recent 
  Future<void> init() async {
    final recent = await PrefHelper.loadRecentSearches();
    emit(state.copyWith(recentSearches: recent));
  }

  // ── Called on every keystroke ──
  void onQueryChanged(String query) {
    _debounce?.cancel();

    if (query.trim().isEmpty) {
      emit(state.copyWith(status: SearchStatus.idle, query: ''));
      return;
    }

    emit(state.copyWith(status: SearchStatus.loading, query: query));

    _debounce = Timer(const Duration(milliseconds: 350), () {
      _runSearch(query, state.filter);
    });
  }

  // ── Execute search with current filter ──
  Future<void> _runSearch(String query, SearchFilter filter)async {
    try {
      final results = _repository.search(query: query, filter: filter);
      final recentSearches= await PrefHelper.loadRecentSearches();
   
      emit(
        state.copyWith(
          status: results.isEmpty ? SearchStatus.empty : SearchStatus.results,
          results: results,
          query: query,
          filter: filter,
          recentSearches: recentSearches,
          
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: SearchStatus.error,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  // ── Apply a new filter and re-search ──
  void applyFilter(SearchFilter filter) {
    if (state.query.trim().isEmpty) {
      emit(state.copyWith(filter: filter));
      return;
    }
    _runSearch(state.query, filter);
  }

  // ── Tap a recent or trending chip ──
  Future<void> selectSuggestion(String query)async {
    fieldController.text = query;
    fieldController.selection = TextSelection.fromPosition(
      TextPosition(offset: query.length),
    );
    emit(state.copyWith(status: SearchStatus.loading, query: query));
   await _repository.saveSearch(query);
    _runSearch(query, state.filter);
  }

  // ── Save to history on submit (keyboard done) ──
  Future<void> onSubmitted(String query) async {
    if (query.trim().isEmpty) return;
    await _repository.saveSearch(query.trim());
    final recent = await PrefHelper.loadRecentSearches();
    emit(state.copyWith(recentSearches: recent));
  }

  // ── Remove one recent search ──
  Future<void> removeRecent(String query) async {
    await _repository.removeRecentSearch(query);
    final recent = await PrefHelper.loadRecentSearches();
    emit(state.copyWith(recentSearches: recent));
  }

  // ── Clear all recent searches ──
  Future<void> clearAllRecent() async {
    await PrefHelper.clearRecentSearches();
    emit(state.copyWith(recentSearches: []));
  }

  // ── Clear the field and go back to idle ──
  void clearQuery() {
    _debounce?.cancel();
    fieldController.clear();
    emit(
      state.copyWith(
        status: SearchStatus.idle,
        query: '',
        results: [],
        filter: const SearchFilter(),
      ),
    );
  }

  List<Product> getTrending() => _repository.getTrending();

  @override
  Future<void> close() {
    _debounce?.cancel();
    fieldController.dispose();
    return super.close();
  }
}
