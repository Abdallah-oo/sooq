import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:market_salla/shared/snackbar.dart';
import 'package:market_salla/widgets/registration/image/modelbuttom.dart';

class Custompickimage extends StatefulWidget {
  const Custompickimage({super.key, required this.ispicked});
  final Function(bool) ispicked;

  @override
  State<Custompickimage> createState() => _CustompickimageState();
}

class _CustompickimageState extends State<Custompickimage> {
  File? imgpath;
  pickimg(ImageSource type) async {
    try {
      final chossedimg = await ImagePicker().pickImage(source: type);
      if (chossedimg != null) {
        imgpath = File(chossedimg.path);
        widget.ispicked(true);
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Error happend try again');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            backgroundColor: const Color.fromARGB(255, 253, 253, 253),
            radius: 60,
            child: (imgpath == null)
                ? const CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage('assets/img/avatar.jpg'),
                  )
                : ClipOval(
                    child: Image.file(
                      imgpath!,
                      fit: BoxFit.fill,
                      height: 200,
                      width: 200,
                    ),
                  ),
          ),

          Positioned(
            top: 88,
            left: 83,
            child: IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Custommodelbuttomsheet(
                      imgpath: imgpath,
                      camera: ()async {
                        await pickimg(ImageSource.camera);
                      },
                      delete: () {
                        setState(() {
                          imgpath = null;
                        });
                      },
                      gallary: ()async {
                      await pickimg(ImageSource.gallery);
                      },
                    );
                  },
                );
              },
              icon: const Icon(
                Icons.camera_alt,
                color: Color.fromARGB(234, 15, 211, 58),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
