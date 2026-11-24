import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sooq/features/Address/data/models/address_model.dart';
import 'package:sooq/features/Address/data/repos/address_repo.dart';

part 'address_form_state.dart';

class AddressFormCubit extends Cubit<AddressFormState> {
  AddressFormCubit(this._repo) : super(const AddressFormState());

  final AddressRepo _repo;

  Future<void> save(AddressModel address, {required bool isEdit}) async {
    if (state.status == AddressFormStatus.saving) return;
    emit(const AddressFormState(status: AddressFormStatus.saving));

    final result = isEdit ? await _repo.updateAddress(address) : await _repo.addAddress(address);

    result.fold(
      (e) => emit(AddressFormState(status: AddressFormStatus.failure, errorMessage: e.message)),
      (_) => emit(const AddressFormState(status: AddressFormStatus.success)),
    );
  }
}
