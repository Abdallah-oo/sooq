import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sooq/features/Address/data/models/address_model.dart';
import 'package:sooq/features/Address/data/repos/address_repo.dart';

part 'addresses_state.dart';

class AddressesCubit extends Cubit<AddressesState> {
  AddressesCubit(this._repo) : super(const AddressesState());

  final AddressRepo _repo;

  /// [silent] keeps the current list on screen (pull-to-refresh, after
  /// add / edit / delete) and reports failures as a transient `actionError`.
  Future<void> fetchAddresses({bool silent = false}) async {
    if (!silent) emit(state.copyWith(isLoading: true));

    final result = await _repo.getAddresses();
    result.fold(
      (e) => emit(
        silent
            ? state.copyWith(isMutating: false, actionError: e.message)
            : state.copyWith(isLoading: false, isMutating: false, loadError: e.message),
      ),
      (list) => emit(state.copyWith(isLoading: false, isMutating: false, addresses: list)),
    );
  }

  Future<void> deleteAddress(String id) async {
    if (state.isMutating) return;
    emit(state.copyWith(isMutating: true));

    final result = await _repo.deleteAddress(id);
    await result.fold(
      (e) async => emit(state.copyWith(isMutating: false, actionError: e.message)),
      (_) => fetchAddresses(silent: true),
    );
  }

  Future<void> setDefault(String id) async {
    if (state.isMutating) return;
    emit(state.copyWith(isMutating: true));

    final result = await _repo.setDefault(id);
    await result.fold(
      (e) async => emit(state.copyWith(isMutating: false, actionError: e.message)),
      (_) => fetchAddresses(silent: true),
    );
  }
}
