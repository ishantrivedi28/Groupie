import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;

  DatabaseService({this.uid});

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection('groups');

  Future saveUserData(String fullName, String email) async {
    return await userCollection.doc(uid).set({
      'fullname': fullName,
      'email': email,
      'groups': [],
      'profilePic': '',
      'uid': uid,
    });
  }

  //getting userdata

  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where('email', isEqualTo: email).get();
    return snapshot;
  }

  //getting user groups
  getUserGroups() async {
    return userCollection.doc(uid).snapshots();
  }

  Future<List<String>> getAllGroupNames() async {
    QuerySnapshot snaps = await groupCollection.get();
    List<String> allGroupNames = [];

    for (var x in snaps.docs) {
      allGroupNames.add(x['groupName']);
    }
    return allGroupNames;
  }

  //creating a group
  Future createGroup(String userName, String uid, String groupName) async {
    DocumentReference groupDocumentReference = await groupCollection.add({
      'groupName': groupName,
      'groupIcon': '',
      'admin': '${uid}_$userName',
      'members': [],
      'groupId': '',
      'recentMessage': '',
      'recentMessageSender': ''
    });

    await groupDocumentReference.update({
      'members': FieldValue.arrayUnion(["${uid}_${userName}"]),
      'groupId': groupDocumentReference.id
    });
    DocumentReference userDocumentReference = userCollection.doc(uid);
    await userDocumentReference.update({
      'groups':
          FieldValue.arrayUnion(['${groupDocumentReference.id}_$groupName'])
    });
  }

  //getting the chats
  getChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection('messages')
        .orderBy('time')
        .snapshots();
  }

  getGroupAdmin(String groupId) async {
    DocumentReference d = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot['admin'];
  }

  getGroupMembers(groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  //search
  searchByGroupName(String groupName) async {
    QuerySnapshot snaps = await groupCollection.get();
    var snapshots = [];

    for (var x in snaps.docs) {
      if (groupName.trim().toLowerCase() ==
          x['groupName'].toString().toLowerCase()) {
        snapshots.add(x);
      }
    }

    if (snapshots.isNotEmpty) {
      return groupCollection
          .where('groupName', isEqualTo: snapshots[0]['groupName'])
          .get();
    } else {
      return null;
    }
  }

  Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();

    List<dynamic> groups = await documentSnapshot['groups'];
    if (groups.contains("${groupId}_${groupName}")) {
      return true;
    } else {
      return false;
    }
  }

  Future toggleGroupJoin(
      String groupId, String userName, String groupName) async {
    // doc reference
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);

    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List<dynamic> groups = await documentSnapshot['groups'];

    // if user has our groups -> then remove then or also in other part re join
    if (groups.contains("${groupId}_$groupName")) {
      await userDocumentReference.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayRemove(["${uid}_$userName"])
      });
    } else {
      await userDocumentReference.update({
        "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayUnion(["${uid}_$userName"])
      });
    }
  }

  sendText(String groupId, Map<String, dynamic> messageData) async {
    groupCollection.doc(groupId).collection('messages').add(messageData);
    groupCollection.doc(groupId).update({
      'recentMessage': messageData['message'],
      'recentMessageSender': messageData['sender'],
      'recentMessageTime': messageData['time'].toString()
    });
  }
}
