import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class ListScreen extends StatefulWidget {
  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List of files'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Files')
            .orderBy('date')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          return ListView(
            padding: const EdgeInsets.all(8),
            children: snapshot.data!.docs.map((document) {
              return Center(
                child: Container(
                  width: MediaQuery.of(context).size.width / 1.2,
                  height: MediaQuery.of(context).size.width / 4.5,
                  child: InkWell(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(document.get('name')),
                        SizedBox(height: 5),
                        Text(document.get('type')),
                        SizedBox(height: 5),
                        Text(document
                            .get('date')
                            .toDate()
                            .toString()
                            .split(' ')[0]),
                        SizedBox(height: 10),
                      ],
                    ),
                    onTap: () {
                      _launchInWebViewOrVC(document.get('url'));
                    },
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

Future<void> _launchInWebViewOrVC(String url) async {
  if (await canLaunch(url)) {
    await launch(
      url,
      // forceSafariVC: true,
      forceWebView: true,
      // headers: <String, String>{'my_header_key': 'my_header_value'},
    );
  } else {
    throw 'Could not launch $url';
  }
}

//     body: StreamBuilder(
//       stream: FirebaseFirestore.instance.collection('Files').snapshots(),
//       builder: buildUserList,
//     ),
//   );
// }

// Widget buildUserList(
//     BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//   if (snapshot.hasData) {
//     return ListView.builder(
//       itemCount: snapshot.data!.docs.length,
//       itemBuilder: (context, index) {
//         DocumentSnapshot user = snapshot.data!.docs[index];

//         return ListTile(
//           // Access the fields as defined in FireStore
//           title: Text(user.get('name')),
//           subtitle: Text(user.get('type')),
//           onTap: () {
//             Scaffold(
//               body: Container(
//                 child: Column(
//                   children: [
//                     Text(user.get('url')),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   } else if (snapshot.connectionState == ConnectionState.done &&
//       !snapshot.hasData) {
//     // Handle no data
//     return Center(
//       child: Text("No users found."),
//     );
//   } else {
//     // Still loading
//     return CircularProgressIndicator();
//   }
