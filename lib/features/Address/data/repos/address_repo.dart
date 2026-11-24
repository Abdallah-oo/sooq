import 'package:dartz/dartz.dart';
import 'package:sooq/core/services/supabase/errors/supabase_error.dart';
import 'package:sooq/features/Address/data/models/address_model.dart';

abstract interface class AddressRepo {
  /// Default address first, then newest first.
  Future<Either<SupabaseError, List<AddressModel>>> getAddresses();

  Future<Either<SupabaseError, AddressModel>> addAddress(AddressModel address);

  Future<Either<SupabaseError, AddressModel>> updateAddress(AddressModel address);

  Future<Either<SupabaseError, Unit>> deleteAddress(String id);

  /// The DB trigger un-marks the previous default.
  Future<Either<SupabaseError, Unit>> setDefault(String id);
}
