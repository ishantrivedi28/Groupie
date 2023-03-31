import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:groupie/pages/home_page.dart';
import 'package:groupie/services/database_service.dart';
import 'package:groupie/shared/constants.dart';

class GroupInfoPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String adminName;
  const GroupInfoPage(
      {super.key,
      required this.adminName,
      required this.groupId,
      required this.groupName});

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  Stream? members;
  @override
  void initState() {
    getMemebrs();
    super.initState();
  }

  getMemebrs() {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupMembers(widget.groupId)
        .then((value) {
      setState(() {
        members = value;
      });
    });
  }

  String getId(String res) {
    return res.substring(0, res.indexOf('_'));
  }

  getName(String r) {
    return r.substring(r.indexOf('_') + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("Group Info"),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Exit"),
                      content: Text("Are you sure you want to exit the group?"),
                      actions: [
                        IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.cancel,
                              color: Colors.red,
                            )),
                        IconButton(
                            onPressed: () async {
                              DatabaseService(
                                      uid: FirebaseAuth
                                          .instance.currentUser!.uid)
                                  .toggleGroupJoin(
                                      widget.groupId,
                                      getName(widget.adminName),
                                      widget.groupName)
                                  .whenComplete(() {
                                Constants.nextScreenReplace(
                                    context, HomePage());
                              });
                            },
                            icon: const Icon(
                              Icons.done,
                              color: Colors.green,
                            ))
                      ],
                    );
                  });
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Constants.primaryColor.withOpacity(0.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Constants.primaryColor,
                  child: Text(
                    widget.groupName.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                        fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Group: ${widget.groupName}",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text("Admin: ${getName(widget.adminName)}"),
                  ],
                )
              ],
            ),
          ),
          memberList()
        ]),
      ),
    );
  }

  memberList() {
    return StreamBuilder(
      stream: members,
      builder: ((context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['members'] != null) {
            if (snapshot.data['members'].length != 0) {
              return ListView.builder(
                  itemCount: snapshot.data['members'].length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundColor: Constants.primaryColor,
                          child: Text(
                            getName(snapshot.data['members'][index])
                                .substring(0, 1)
                                .toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(getName(snapshot.data['members'][index])),
                        subtitle: Text(getId(snapshot.data['members'][index])),
                      ),
                    );
                  });
            } else {
              return Center(
                child: Text("NO MEMBERS"),
              );
            }
          } else {
            return Center(
              child: Text("NO MEMBERS"),
            );
          }
        } else {
          return Center(
              child: CircularProgressIndicator(
            color: Constants.primaryColor,
          ));
        }
      }),
    );
  }
}
