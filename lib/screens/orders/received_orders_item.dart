


import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../l10n/locale_keys.g.dart';

class ReceivedOrdersItem extends StatefulWidget {

  AsyncSnapshot snapshot;
  int index;

  ReceivedOrdersItem({Key? key, required this.snapshot, required this.index}) : super(key: key);


  @override
  _ReceivedOrdersItemState createState() => _ReceivedOrdersItemState();
}


class _ReceivedOrdersItemState extends State<ReceivedOrdersItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${LocaleKeys.orderId.tr()}: ${widget.snapshot.data.docs[widget.index].id}',
              style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: MediaQuery.of(context).size.width*0.032),
            ),
            Text(
              '${LocaleKeys.orderName.tr()}: ${widget.snapshot.data.docs[widget.index]['buyer_name']}',
              style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: MediaQuery.of(context).size.width*0.033),
            ),
          ],
        ),
        subtitle: Text(
          '${LocaleKeys.orderDate.tr()} ${DateFormat.yMMMd().format(widget.snapshot.data.docs[widget.index]['created_at'].toDate())} at ${DateFormat.jm().format(widget.snapshot.data.docs[widget.index]['created_at'].toDate())}',
          style: TextStyle(
              fontFamily: 'Lato',
              fontSize: MediaQuery.of(context).size.width*0.038),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${LocaleKeys.orderStatus.tr()}: ${widget.snapshot.data.docs[widget.index]['order_status']}',
              style: TextStyle(
                  color: widget.snapshot.data.docs[widget.index]['order_status'] == "done"? Colors.green:widget.snapshot.data.docs[widget.index]['order_status'] == "cancelled"?Colors.red:Colors.black,
                  fontSize: MediaQuery.of(context).size.width*0.038),
            ),
          ],
        ),
      ),
    );
  }
}