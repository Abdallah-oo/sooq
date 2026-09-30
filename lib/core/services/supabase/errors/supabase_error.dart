class SupabaseError implements Exception{
  final String message;

  SupabaseError({ required this.message});

  @override
  String toString() {
    return message;
  }
}
