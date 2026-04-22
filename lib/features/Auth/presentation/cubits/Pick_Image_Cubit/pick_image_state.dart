part of 'pick_image_cubit.dart';

@immutable
sealed class PickImageState {
  const PickImageState();
}

/// الحالة الأولية قبل أي action
final class PickImageInitial extends PickImageState {
  const PickImageInitial();
}

/// جاري تحميل الصورة أو المعالجة
final class PickImageLoading extends PickImageState {
  const PickImageLoading();
}

/// تم اختيار الصورة بنجاح
final class PickImageSuccess extends PickImageState {
  final File imageFile;

  const PickImageSuccess({required this.imageFile});
}

/// حدث خطأ أثناء اختيار الصورة أو المعالجة
final class PickImageFailure extends PickImageState {
  final String errorMessage;

  const PickImageFailure({required this.errorMessage});
}

/// تم حذف الصورة
final class PickImageDeleted extends PickImageState {
  const PickImageDeleted();
}
