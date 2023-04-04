import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:groupie/services/database_service.dart';

import '../pages/chat_page.dart';
import '../shared/constants.dart';

class GroupTile extends StatefulWidget {
  final String userName;
  final String groupId;
  final String groupName;

  GroupTile(
      {super.key,
      required this.groupId,
      required this.groupName,
      required this.userName,
      r});

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  Stream<DocumentSnapshot>? stream;

  getLastMessage() async {
    print(widget.groupName);
    CollectionReference groupCollection = DatabaseService().groupCollection;
    DocumentReference query = groupCollection.doc(widget.groupId);
    setState(() {
      stream = query.snapshots();
    });

    //       List<DocumentSnapshot> docssnapshots = stream.docs();

    //  documentSnapshots[0]
  }

  @override
  void initState() {
    print(widget.groupId);
    getLastMessage();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Constants.nextScreen(
              context,
              ChatPage(
                groupId: widget.groupId,
                groupName: widget.groupName,
                userName: widget.userName,
              ));
        },
        child: StreamBuilder(
            stream: stream,
            builder: (context, snapshot) => snapshot.hasData
                ? Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          widget.groupName.substring(0, 1).toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ),
                      title: Text(
                        widget.groupName,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text(
                        snapshot.data!['recentMessageSender'].toString() == ""
                            ? "Tap to start a new chat"
                            : "${snapshot.data!['recentMessageSender']}: ${snapshot.data!['recentMessage']}",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  )
                : Container()));
  }
}
