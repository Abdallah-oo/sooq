import 'package:dartz/dartz.dart';
import 'package:sooq/core/services/supabase/errors/supabase_error.dart';
import 'package:sooq/core/services/supabase/errors/supabase_error_handler.dart';
import 'package:sooq/features/Address/data/models/address_model.dart';
import 'package:sooq/features/Address/data/repos/address_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddressRepoImpl implements AddressRepo {
  AddressRepoImpl(this._client);

  final SupabaseClient _client;
  static const String _table = 'addresses';

  @override
  Future<Either<SupabaseError, List<AddressModel>>> getAddresses() async {
    try {
      final response = await _client
          .from(_table)
          .select()
          .order('is_default', ascending: false)
          .order('created_at', ascending: false);

      final addresses = (response as List)
          .map((row) => AddressModel.fromJson(row as Map<String, dynamic>))
          .toList();
      return Right(addresses);
    } catch (e) {
      return Left(SupabaseErrorHandler.handleSupabaseError(e));
    }
  }

  @override
  Future<Either<SupabaseError, AddressModel>> addAddress(AddressModel address) async {
    try {
      final row = await _client.from(_table).insert(address.toJson()).select().single();
      return Right(AddressModel.fromJson(row));
    } catch (e) {
      return Left(SupabaseErrorHandler.handleSupabaseError(e));
    }
  }

  @override
  Future<Either<SupabaseError, AddressModel>> updateAddress(AddressModel address) async {
    try {
      final row = await _client
          .from(_table)
          .update(address.toJson())
          .eq('id', address.id)
          .select()
          .single();
      return Right(AddressModel.fromJson(row));
    } catch (e) {
      return Left(SupabaseErrorHandler.handleSupabaseError(e));
    }
  }

  @override
  Future<Either<SupabaseError, Unit>> deleteAddress(String id) async {
    try {
      await _client.from(_table).delete().eq('id', id);
      return const Right(unit);
    } catch (e) {
      return Left(SupabaseErrorHandler.handleSupabaseError(e));
    }
  }

  @override
  Future<Either<SupabaseError, Unit>> setDefault(String id) async {
    try {
      await _client.from(_table).update({'is_default': true}).eq('id', id);
      return const Right(unit);
    } catch (e) {
      return Left(SupabaseErrorHandler.handleSupabaseError(e));
    }
  }
}
