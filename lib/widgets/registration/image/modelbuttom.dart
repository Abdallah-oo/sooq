import 'dart:io';
import 'package:flutter/material.dart';
class Custommodelbuttomsheet extends StatefulWidget {
  const Custommodelbuttomsheet({
    super.key,
    required this.delete,
    required this.camera,
    required this.gallary, required this.imgpath,
  });
  final File? imgpath;
  final VoidCallback delete;
  final VoidCallback camera;
  final VoidCallback gallary;

  @override
  State<Custommodelbuttomsheet> createState() => _CustommodelbuttomsheetState();
}

class _CustommodelbuttomsheetState extends State<Custommodelbuttomsheet> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Column(
        children: [
          const SizedBox(height: 5),

          const Text(
            'select image',
            style: TextStyle(
              fontSize: 17,
              color: Color.fromARGB(255, 139, 118, 101),
              fontWeight: FontWeight.bold,
            ),
          ),

          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        widget.camera();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.camera_alt),
                    ),
                    const Text('camera'),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        widget.gallary();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.photo_library),
                    ),
                    const Text('gallary'),
                  ],
                ),
                (widget.imgpath == null)
                    ? const SizedBox.shrink()
                    : Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              widget.delete();
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
                          const Text(
                            'delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
