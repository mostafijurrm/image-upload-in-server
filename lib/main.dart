import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'Image Upload in PHP Server'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String status = 'Image Uploaded Successfully';
  String base64Image;
  File tempFile;
  String errMsg = 'Error Uploading Image';
  String message = 'Loading';
  Future<File> file;
  static final String uploadEndPoint = 'http://localhost/upload.php';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlineButton(
              child: Text('Choose Image'),
              onPressed: chooseImageFromGallery,
            ),
            SizedBox(height: 20.0,),
            ShowImage(),
            SizedBox(height: 20.0,),
            OutlineButton(
              child: Text('Upload Image'),
              onPressed: uploadImageInServer,
            ),
            SizedBox(height: 20.0,),
            Text(
              status,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.green,
                fontSize: 20.0,
                fontWeight: FontWeight.w500
              ),
            )
          ],
        ),
      ),
    );
  }

  chooseImageFromGallery() {
    setState(() {
      file = ImagePicker.pickImage(source: ImageSource.gallery);
    });
  }

  Widget ShowImage(){
    return FutureBuilder<File>(
      future: file,
      // ignore: missing_return
      builder: (BuildContext context, AsyncSnapshot<File> snapshot){
        if(snapshot.connectionState == ConnectionState.done && null != snapshot.data){
          tempFile = snapshot.data;
          base64Image = base64Encode(snapshot.data.readAsBytesSync());
          return Flexible(
            child: Image.file(snapshot.data,
              fit: BoxFit.fill,
            ),
          );
        }
        else if(null != snapshot.error){
          return Text('Error Picking Image');
        }
        else{
          return Text('No Image Selected');
        }
      },
    );
  }
  setStatus(String msg){
    setState(() {
      status = msg;
    });
  }
  uploadImageInServer() {
    setStatus('Image Uploading...');
    if(null == tempFile){
      setStatus(errMsg);
      return;
    }
    String fileName = tempFile.path.split('/').last;
    upload(fileName);
  }

  void upload(String fileName) {
    http.post(uploadEndPoint, body: {
      'image': base64Image,
      'name': fileName,
    }).then((value) {
      setStatus(value.statusCode == 200 ? value.body:errMsg);
    }).catchError((onError){
      setStatus(onError);
    });
    }
}
