import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';

class Test_model extends StatefulWidget {
  const Test_model({super.key});

  @override
  State<Test_model> createState() => _Test_modelState();
}

class _Test_modelState extends State<Test_model> {
  late File _image;
  late List _results;
  bool pictureSelect = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadModel();
  }

  Future loadModel() async {
    Tflite.close();
    String res;
    res = (await Tflite.loadModel(
      model: 'assets/best-fp16.tflite',
      labels: 'assets/labels.txt',
    ))!;
    print("model Loading status = $res");
  }

  Future imageClassification(File image) async {
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    setState(() {
      _results = recognitions!;
      _image = image;
      pictureSelect = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('model Test'),
      ),
      body: ListView(
        children: [
          (pictureSelect)
              ? Container(
                  margin: const EdgeInsets.all(10),
                  child: Image.file(_image),
                )
              : Container(
                  margin: const EdgeInsets.all(10),
                  child: const Opacity(
                    opacity: 0.8,
                    child: Text('No image Selected'),
                  ),
                ),
          SingleChildScrollView(
            child: Column(
              children: (pictureSelect)
                  ? _results.map((result) {
                      return Card(
                          child: Container(
                        margin: const EdgeInsets.all(10),
                        child: Text(
                          "${result['label']} - ${result['confidence'].toStringAsFixed(2)}",
                          style:
                              const TextStyle(color: Colors.red, fontSize: 20),
                        ),
                      ));
                    }).toList()
                  : [],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickImage,
        tooltip: "image Pick",
      ),
    );
  }

  Future pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    File image = File(pickedFile!.path);
    imageClassification(image);
  }
}
