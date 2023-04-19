

import 'dart:io';
import 'dart:core';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class GalleryAccess extends StatefulWidget {
  const GalleryAccess({super.key});

  @override
  State<GalleryAccess> createState() => _GalleryAccessState();
}

class _GalleryAccessState extends State<GalleryAccess> {
  File? galleryFile;
  final picker = ImagePicker();
  final storage = FirebaseStorage.instanceFor(
      bucket: "gs://my-custom-bucket");

  bool _containsNudity = false;

  @override
  Widget build(BuildContext context) {
    //display image selected from gallery

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profanity filter'),
        backgroundColor: Colors.green,
        actions: const [],
      ),
      body: Builder(
        builder: (BuildContext context) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [SizedBox(
                height: 200.0,
                width: 300.0,
                child: galleryFile == null
                    ?  Text('Sorry nothing selected!!')
                    : Image.file(galleryFile!),
              ),
                Padding(
                  padding: const EdgeInsets.only(top: 250,left: 200),
                  child: IconButton(onPressed: (){
                    _showPicker(context: context);
                  },
                    icon: Icon(Icons.add, size: 50,),
                    color: Colors.purpleAccent,),
                ),


              ],
            ),
          );
        },
      ),
    );
  }

  void _showPicker({
    required BuildContext context,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  getImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  getImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future getImage(
      ImageSource img,
      ) async {
    final pickedFile = await picker.pickImage(source: img);
    XFile? xfilePick = pickedFile;
    setState(
          () {
        if (xfilePick != null) {
          galleryFile = File(pickedFile!.path);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(// is this context <<<
              const SnackBar(content: Text('Nothing is selected')));
        }
      },
    );
  }
  Future<void> _uploadImage() async {
    final storage = FirebaseStorage.instance;
    final ref = storage.ref().child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(ImagePicker() as File);
    final url = await ref.getDownloadURL();
    setState(() {

    });
  }

  Future<void> _detectNudity() async {
    if (galleryFile!= null) {
      final visionImage = InputImage.fromFile(galleryFile!);
      final imageLabeler = GoogleMlKit.vision.imageLabeler();
      final labels = await imageLabeler.processImage(visionImage);
      bool containsNudity = false;
      labels.forEach((label) {
        if (label.index == 'Nudity' && label.confidence >= 0.5) {
          containsNudity = true;
        }
      });
      setState(() {
        _containsNudity = containsNudity;
      });
    }
  }

}