import "package:flutter/material.dart";

class ChatMessage extends StatelessWidget {
  ChatMessage(this.data, this._mine);

  final Map data;
  final bool _mine;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: <Widget>[
          !_mine ? Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(data["url"]),
            ),
          ) : Container(),
          Expanded(
              child: Column(
            crossAxisAlignment: _mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[
              data["imgUrl"] != null
                  ? Image.network(
                      data["imgUrl"],
                      width: 250.0,
                    )
                  : Text(
                      data["text"],
                      textAlign: _mine ? TextAlign.end : TextAlign.start ,
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
              Text(data["name"],
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500))
            ],
          ),

          ),
          _mine ? Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(data["url"]),
            ),
          ) : Container()
        ],
      ),
    );
  }
}
