import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:universal_html/html.dart';

class Tile extends StatefulWidget {
  final bool hasMine;
  final int surroundTrapCount;
  final Map<String, int> position;
  final int retryNumber;
  final void Function() onZeroClick;
  final void Function() notifyParentToAutoOpen;
  final void Function() notifyTrapClicked;
  Tile({
    super.key,
    required this.hasMine,
    required this.surroundTrapCount,
    required this.position,
    required this.retryNumber,
    required this.onZeroClick,
    required this.forceOpen,
    required this.notifyParentToAutoOpen,
    required this.notifyTrapClicked,
  });
  bool forceOpen = false;
  bool clicked = false;
  bool rightClicked = false;
  @override
  State<Tile> createState() => _TileState();
}

class _TileState extends State<Tile> {
  bool hovering = false;
  final Map<int, Color> trapCountColors = {
    0: Colors.black,
    1: Colors.blue,
    2: Colors.green,
    3: Colors.red,
    4: Colors.deepPurple,
    5: Color.fromRGBO(241, 51, 255, 1),
    6: Colors.cyan,
    7: Colors.purple,
    8: Colors.grey,
  };
  @override
  void didUpdateWidget(covariant Tile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.clicked && widget.clicked == false) {
      widget.clicked = true;
    }
    if (oldWidget.rightClicked) {
      widget.rightClicked = true;
    }
    if (widget.forceOpen) {
      widget.clicked = true;
    }
    if (oldWidget.retryNumber != widget.retryNumber) {
      resetTile();
    }
  }

  void resetTile() {
    widget.clicked = false;
    widget.rightClicked = false;
  }

  void initState() {
    document.onContextMenu.listen((event) {
      event.preventDefault();
    });
  }

  void click() {
    setState(() {
      if (widget.surroundTrapCount == 0 && !widget.hasMine) {
        widget.onZeroClick();
      } else {
        widget.clicked = true;
        if (widget.hasMine) {
          widget.notifyTrapClicked();
        }
      }
    });
  }

  void rightClick() {
    setState(() {
      widget.rightClicked = !widget.rightClicked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter:
          (event) => {
            setState(() {
              hovering = true;
            }),
          },
      onExit:
          (event) => {
            setState(() {
              hovering = false;
            }),
          },
      child: Listener(
        onPointerDown: (PointerDownEvent event) {
          if (event.buttons == kSecondaryMouseButton) {
            if (!widget.clicked) {
              rightClick();
            }
          } else {
            // we are clicking the button, if we double click the button that is already clicked, we will check the close surrounding tiles;
            if (!widget.rightClicked) {
              if (!widget.clicked) {
                click();
              } else {
                widget.notifyParentToAutoOpen();
              }
            }
          }
        },

        child: AnimatedContainer(
          duration: Duration(milliseconds: widget.clicked ? 0 : 50),
          decoration: new BoxDecoration(
            color:
                !widget.clicked
                    ? (hovering
                        ? Color.fromARGB(255, 116, 223, 120)
                        : Colors.green)
                    : (widget.hasMine
                        ? Colors.red
                        : ((widget.position["x"]! + widget.position["y"]!) %
                                    2 ==
                                0
                            ? const Color.fromARGB(96, 187, 187, 187)
                            : const Color.fromARGB(179, 201, 201, 201))),
            borderRadius: BorderRadius.all(Radius.circular(5)),
            border: Border.all(width: 1, color: Colors.white),
          ),
          width: 30,
          height: 30,
          child: Center(
            child:
                !widget.clicked
                    ? (widget.rightClicked
                        ? Icon(Icons.flag, color: Colors.red)
                        : Text(""))
                    : (widget.hasMine
                        ? Text("")
                        : Text(
                          widget.surroundTrapCount != 0
                              ? widget.surroundTrapCount.toString()
                              : "",
                          style: TextStyle(
                            fontFamily: "Arial",
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: trapCountColors[widget.surroundTrapCount],
                          ),
                        )),
          ),
        ),
      ),
    );
  }
}
