import 'package:flutter/material.dart';
import 'package:notte_chat/core/extensions/date_extension.dart';
import 'package:notte_chat/shared/style/color.dart';

class BusyOverlay extends StatelessWidget {
  final Widget? child;
  final String title;
  final bool show;
  final double? height;
  final double opacity;

  const BusyOverlay({
    super.key,
    this.child,
    this.title = 'Processing document(s)...',
    this.show = false,
    this.height,
    this.opacity = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        color: Colors.transparent,
        child: Stack(
          children: <Widget>[
            child!,
            IgnorePointer(
              ignoring: !show,
              child: Opacity(
                opacity: show ? 1.0 : 0.0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: height ?? MediaQuery.of(context).size.height,
                  alignment: Alignment.center,
                  color: Theme.of(context).textTheme.titleMedium!.color!.withOpacity(opacity),
                  // color: Colors.grey,
                  //color: const Color.fromARGB(100, 0, 0, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: primaryColor,
                          backgroundColor: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      // const Image(
                      //   image: AssetImage("assets/logo.png"),
                      //   width: 50,
                      // ),
                      const SizedBox(height: 10),
                      Text(
                        title.cap,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // SizedBox(
                      //   height: height.toDouble(),
                      // )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
