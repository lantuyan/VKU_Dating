import 'package:flutter/material.dart';

class BeautifulAlertDialog extends StatelessWidget {
  final String text;
  final Function onYesTap;
  final Function onNoTap;

  BeautifulAlertDialog({
    required this.text,
    required this.onYesTap,
    required this.onNoTap,
  });
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Dialog(
        insetAnimationCurve: Curves.bounceInOut,
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.only(right: 10.0),
          height: 130,
          width: MediaQuery.of(context).size.width * .4,
          decoration: BoxDecoration(
            color: Color(0xff333333),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(75),
              bottomLeft: Radius.circular(75),
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Color(0xff333333),
                    child: Icon(Icons.error_outline),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Alert!",
                        // style: Theme.of(context).textTheme.title,
                      ),
                      Text(text),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                              ),
                              child: Text("No"),
                              onPressed: () => onNoTap(),
                            ),
                          ),
                          SizedBox(width: 10.0),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                              ),
                              child: Text("Yes"),
                              onPressed: () => onYesTap(),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
