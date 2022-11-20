import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late ImagePicker _picker;
  late ImageLabeler _imageLabeler;
  List<ImageLabel>? _labels;

  File? _image;

  @override
  void initState() {
    super.initState();
    _picker = ImagePicker();

    ImageLabelerOptions options = ImageLabelerOptions(confidenceThreshold: 0.5);

    _imageLabeler = ImageLabeler(options: options);

    _labels = <ImageLabel>[];
  }

  @override
  void dispose() {
    _imageLabeler.close();
    super.dispose();
  }

  chooseImages() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = File(image.path);

        doImageLabeling();
      });
    }
  }

  captureImages() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _image = File(image.path);

        doImageLabeling();
      });
    }
  }

  doImageLabeling() async {
    if (_image != null) {
      InputImage inputImage = InputImage.fromFile(_image!);

      if (_labels?.isNotEmpty ?? false) _labels?.clear();

      final newLabels = await _imageLabeler.processImage(inputImage);

      setState(() {
        _labels = newLabels;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _image != null
              ? SizedBox(
                  width: 200,
                  height: 300,
                  child: Image.file(
                    _image!,
                    fit: BoxFit.cover,
                  ),
                )
              : const Icon(
                  Icons.image,
                  size: 158,
                ),
          const SizedBox(
            height: 16,
          ),
          ElevatedButton(
            onPressed: chooseImages,
            onLongPress: captureImages,
            child: const Text('Choose os capture'),
          ),
          Expanded(
            child: ListView(
              children: [
                if (_labels?.isNotEmpty ?? false)
                  ..._labels!
                      .map(
                        (e) => Container(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            '${e.label}, ${e.index}, ${e.confidence.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                      )
                      .toList()
              ],
            ),
          )
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
