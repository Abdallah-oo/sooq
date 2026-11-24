part of 'address_form_cubit.dart';

enum AddressFormStatus { initial, saving, success, failure }

class AddressFormState {
  const AddressFormState({this.status = AddressFormStatus.initial, this.errorMessage});

  final AddressFormStatus status;
  final String? errorMessage;
}
