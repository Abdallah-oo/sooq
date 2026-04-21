import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

part 'pick_image_state.dart';

class PickImageCubit extends Cubit<PickImageState> {
  PickImageCubit({ImagePicker? imagePicker, ImageCropper? imageCropper})
    : _imagePicker = imagePicker ?? ImagePicker(),
      _imageCropper = imageCropper ?? ImageCropper(),
      super(const PickImageInitial());

  final ImagePicker _imagePicker;
  final ImageCropper _imageCropper;

  File? _imageFile;

  /// الصورة الحالية المختارة (read-only من الخارج)
  File? get imageFile => _imageFile;

  // ──────────────────────────────────────────────
  // Public Methods
  // ──────────────────────────────────────────────

  /// اختيار صورة من المصدر المحدد مع إمكانية القص لصور البروفايل
  Future<void> pickImage({
    required ImageSource source,
    required bool cropForProfile,
  }) async {
    if (isClosed) return;
    emit(const PickImageLoading());

    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1080,
        maxHeight: 1080,
      );

      if (pickedFile == null) {
        // المستخدم ألغى الاختيار، نرجع للحالة السابقة
        _restorePreviousState();
        return;
      }

      if (cropForProfile) {
        await _cropImage(pickedFile.path);
      } else {
        _setImage(File(pickedFile.path));
      }
    } on Exception catch (e) {
      emit(PickImageFailure(errorMessage: _mapExceptionToMessage(e)));
    }
  }

  /// حذف الصورة المختارة
  void deleteImage() {
    _imageFile = null;
    emit(const PickImageDeleted());
  }

  // ──────────────────────────────────────────────
  // Private Helpers
  // ──────────────────────────────────────────────

  Future<void> _cropImage(String sourcePath) async {
    final CroppedFile? croppedFile = await _imageCropper.cropImage(
      sourcePath: sourcePath,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: _buildCropUiSettings(),
    );

    if (croppedFile == null) {
      // المستخدم ألغى القص
      _restorePreviousState();
      return;
    }

    _setImage(File(croppedFile.path));
  }

  List<PlatformUiSettings> _buildCropUiSettings() {
    return [
      AndroidUiSettings(
        toolbarTitle: 'Crop Image',
        toolbarColor: Colors.black,
        toolbarWidgetColor: Colors.white,
        lockAspectRatio: true,
        cropStyle: CropStyle.circle,
        hideBottomControls: false,
        initAspectRatio: CropAspectRatioPreset.square,
      ),
      IOSUiSettings(
        title: 'Crop Image',
        aspectRatioLockEnabled: true,
        resetAspectRatioEnabled: false,
      ),
    ];
  }

  void _setImage(File file) {
    _imageFile = file;
    emit(PickImageSuccess(imageFile: file));
  }

  void _restorePreviousState() {
    if (_imageFile != null) {
      emit(PickImageSuccess(imageFile: _imageFile!));
    } else {
      emit(const PickImageInitial());
    }
  }

  String _mapExceptionToMessage(Exception e) {
    final message = e.toString().toLowerCase();

    if (message.contains('permission')) {
      return 'Permission denied. Please allow access to camera/gallery.';
    } else if (message.contains('camera')) {
      return 'Camera is not available on this device.';
    } else if (message.contains('storage')) {
      return 'Storage access denied. Please check app permissions.';
    }

    return 'Something went wrong. Please try again.';
  }
}
