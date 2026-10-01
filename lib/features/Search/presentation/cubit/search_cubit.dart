import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sooq/core/utils/ld/pref_helper.dart';
import 'package:sooq/features/Home/data/models/product_model.dart';
import 'package:sooq/features/Search/data/repos/search_repo.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._repository) : super(const SearchState());

  final SearchRepository _repository;
  final TextEditingController fieldController = TextEditingController();

  Timer? _debounce;
  int _requestId = 0; // أي رد id بتاعه قديم بيتجاهل
  int _page = 0;

  Future<void> init() async {
    final recent = await PrefHelper.loadRecentSearches();
    if (isClosed) return;
    emit(state.copyWith(recentSearches: recent));

    final trending = await _repository.getTrending();
    if (isClosed) return;
    trending.fold((_) {}, (names) => emit(state.copyWith(trending: names)));
  }

  // ── Called on every keystroke ──
  void onQueryChanged(String query) {
    _debounce?.cancel();
    _requestId++; // يلغي أي request شغال

    if (query.trim().isEmpty) {
      emit(
        state.copyWith(
          status: SearchStatus.idle,
          query: '',
          results: [],
          isLoadingMore: false,
          hasMore: false,
        ),
      );
      return;
    }

    emit(state.copyWith(status: SearchStatus.loading, query: query));
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _runSearch(query, state.filter);
    });
  }

  Future<void> _runSearch(String query, SearchFilter filter) async {
    final id = ++_requestId;
    final result = await _repository.search(query: query, filter: filter);
    if (isClosed || id != _requestId) return; // رد قديم

    result.fold(
      (error) => emit(state.copyWith(status: SearchStatus.error, errorMessage: error.message)),
      (products) {
        _page = 0;
        emit(
          state.copyWith(
            status: products.isEmpty ? SearchStatus.empty : SearchStatus.results,
            results: products,
            query: query,
            filter: filter,
            isLoadingMore: false,
            hasMore: products.length == SearchRepository.pageSize,
          ),
        );
      },
    );
  }

  // ── Infinite scroll ──
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore || state.status != SearchStatus.results) return;

    final id = _requestId;
    emit(state.copyWith(isLoadingMore: true));

    final result = await _repository.search(
      query: state.query,
      filter: state.filter,
      page: _page + 1,
    );
    if (isClosed || id != _requestId) return;

    result.fold((_) => emit(state.copyWith(isLoadingMore: false)), (more) {
      _page++;
      emit(
        state.copyWith(
          results: [...state.results, ...more],
          isLoadingMore: false,
          hasMore: more.length == SearchRepository.pageSize,
        ),
      );
    });
  }

  void applyFilter(SearchFilter filter) {
    if (state.query.trim().isEmpty) {
      emit(state.copyWith(filter: filter));
      return;
    }
    emit(state.copyWith(status: SearchStatus.loading, filter: filter));
    _runSearch(state.query, filter);
  }

  Future<void> selectSuggestion(String query) async {
    _debounce?.cancel();
    fieldController.text = query;
    fieldController.selection = TextSelection.fromPosition(TextPosition(offset: query.length));
    emit(state.copyWith(status: SearchStatus.loading, query: query));

    await _repository.saveSearch(query);
    final recent = await PrefHelper.loadRecentSearches();
    if (isClosed) return;
    emit(state.copyWith(recentSearches: recent));
    await _runSearch(query, state.filter);
  }

  Future<void> onSubmitted(String query) async {
    if (query.trim().isEmpty) return;
    await _repository.saveSearch(query.trim());
    final recent = await PrefHelper.loadRecentSearches();
    if (isClosed) return;
    emit(state.copyWith(recentSearches: recent));
  }

  Future<void> removeRecent(String query) async {
    await _repository.removeRecentSearch(query);
    final recent = await PrefHelper.loadRecentSearches();
    if (isClosed) return;
    emit(state.copyWith(recentSearches: recent));
  }

  Future<void> clearAllRecent() async {
    await PrefHelper.clearRecentSearches();
    if (isClosed) return;
    emit(state.copyWith(recentSearches: []));
  }

  void clearQuery() {
    _debounce?.cancel();
    _requestId++;
    fieldController.clear();
    emit(
      state.copyWith(
        status: SearchStatus.idle,
        query: '',
        results: [],
        filter: const SearchFilter(),
        isLoadingMore: false,
        hasMore: false,
      ),
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    fieldController.dispose();
    return super.close();
  }
}
