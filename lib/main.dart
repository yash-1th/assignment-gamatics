import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gamatics_india/api/firebase_api.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

import 'Screens/list_screen.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final String title = 'Gamatics Assignment';

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: title,
        theme: ThemeData(primarySwatch: Colors.green),
        home: MainPage(),
      );
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  UploadTask? task;
  File? file;
  String? urlDownload;
  DateTime selectedDate = DateTime.now();

  List<String> types = [
    "pdf",
    "image",
    "word",
    "text",
  ];
  String? dropdownValue = "pdf";
  TextEditingController _namecontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final fileName = file != null ? basename(file!.path) : 'No File Selected';

    return Scaffold(
      appBar: AppBar(
        title: Text(MyApp.title),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.list),
            tooltip: 'List of Files',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ListScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 1.4,
              child: TextFormField(
                controller: _namecontroller,
                decoration: InputDecoration(
                  labelText: "File Name",
                ),
              ),
            ),
            SizedBox(height: 8),
            DropdownButton<String>(
              value: dropdownValue,
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue;
                });
              },
              items: types.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            //date code below
            Text(
              "${selectedDate.toLocal()}".split(' ')[0],
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 5.0,
            ),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              style: ButtonStyle(),
              child: Text(
                'Select date',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              // color: Colors.greenAccent,
            ),
            //select file
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
              ),
              onPressed: selectFile,
              child: Text('Select file'),
            ),
            SizedBox(height: 8),
            Text(
              fileName,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
              ),
              onPressed: () async {
                await uploadFile();
                await addFile(
                  _namecontroller.text,
                  dropdownValue,
                  selectedDate,
                  urlDownload,
                );
              },
              child: Text('Upload file'),
            ),
            SizedBox(height: 20),
            task != null ? buildUploadStatus(task!) : Container(),
          ],
        ),
      ),
    );
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) return;
    final path = result.files.single.path!;

    setState(() => file = File(path));
  }

  Future uploadFile() async {
    if (file == null) return;

    final fileName = basename(file!.path);
    final destination = 'files/$fileName';

    task = FirebaseApi.uploadFile(destination, file!);
    setState(() {});

    if (task == null) return;

    final snapshot = await task!.whenComplete(() {});
    urlDownload = await snapshot.ref.getDownloadURL();

    setState(() {});

    print('Download-Link: $urlDownload');
  }

  Widget buildUploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
        stream: task.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final snap = snapshot.data!;
            final progress = snap.bytesTransferred / snap.totalBytes;
            return CircularProgressIndicator(
              value: progress,
              // backgroundColor: Colors.,
            );
          } else {
            return Container();
          }
        },
      );

  _selectDate(BuildContext context) async {
    final DateTime picked = (await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2021),
    ))!;
    if (picked != selectedDate)
      //  if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }
}

// routes: {
//   // '/': (context) => SignIn(),
//   // '/chartspage': (context) => ChartsDemo(),
//   '/listscreen': (context) => ListScreen(),
// },

// onPressed: () {
//   Navigator.pushNamed(context, '/listscreen');
// },

// ButtonWidget(
//   text: 'Select File',
//   icon: Icons.attach_file,
//   onClicked: selectFile,
// ),
