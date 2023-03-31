import 'package:flutter/material.dart';

class MessageTile extends StatefulWidget {
  final String message;
  final String sender;
  final bool sentByMessage;
  const MessageTile(
      {super.key,
      required this.message,
      required this.sender,
      required this.sentByMessage});

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: widget.sentByMessage ? 0 : 24,
          right: widget.sentByMessage ? 24 : 0),
      alignment:
          widget.sentByMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
        margin: widget.sentByMessage
            ? EdgeInsets.only(left: 30)
            : EdgeInsets.only(right: 30),
        decoration: BoxDecoration(
            borderRadius: widget.sentByMessage
                ? BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  )
                : BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
            color: widget.sentByMessage
                ? Theme.of(context).primaryColor
                : Colors.grey[700]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.sender.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  letterSpacing: -0.5,
                  fontSize: 13,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 13),
            )
          ],
        ),
      ),
    );
  }
}
