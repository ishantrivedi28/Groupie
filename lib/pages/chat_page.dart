import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:groupie/pages/group_info_page.dart';
import 'package:groupie/services/database_service.dart';
import 'package:groupie/shared/constants.dart';
import 'package:groupie/widgets/message_tile.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;
  ChatPage(
      {super.key,
      required this.groupId,
      required this.groupName,
      required this.userName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String admin = '';
  Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();
  @override
  void initState() {
    getChatandAdmin();
    super.initState();
  }

  getChatandAdmin() {
    DatabaseService().getChats(widget.groupId).then((val) {
      setState(() {
        chats = val;
      });
    });

    DatabaseService().getGroupAdmin(widget.groupId).then((val) {
      setState(() {
        admin = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(widget.groupName),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
              onPressed: () {
                Constants.nextScreen(
                    context,
                    GroupInfoPage(
                      groupId: widget.groupId,
                      groupName: widget.groupName,
                      adminName: admin,
                    ));
              },
              icon: Icon(Icons.info))
        ],
      ),
      body: Column(
        children: [
          chatMessages(),
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              color: Colors.grey[700],
              child: Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: messageController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Send Message",
                      hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
                GestureDetector(
                  onTap: () {
                    sendMessages();
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ]),
            ),
          )
        ],
      ),
    );
  }

  chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? Expanded(
                child: ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    return MessageTile(
                        message: snapshot.data
                                .docs[snapshot.data.docs.length - 1 - index]
                            ['message'],
                        sender: snapshot.data
                                .docs[snapshot.data.docs.length - index - 1]
                            ['sender'],
                        sentByMessage: widget.userName ==
                            snapshot.data
                                    .docs[snapshot.data.docs.length - 1 - index]
                                ['sender']);
                  },
                ),
              )
            : Container();
      },
    );
  }

  sendMessages() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        'message': messageController.text,
        'sender': widget.userName,
        'time': DateTime.now().microsecondsSinceEpoch
      };

      DatabaseService().sendText(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
  }
}
