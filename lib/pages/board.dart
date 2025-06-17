import 'dart:math';

import 'package:flutter/material.dart';
import 'package:minesweeper/widgets/tile.dart';

class board extends StatefulWidget {
  const board({super.key});

  @override
  State<board> createState() => _boardState();
}

class _boardState extends State<board> {
  int retryNumber = 1;
  int trapsCount = 100;
  int width = 20;
  int height = 20;
  List<List<Map<String, int>>> traps = [];
  int usedTraps = 0;
  int remainingTiles = 0;
  Map<int, List<int>> forceOpen = {};
  Map<int, List<int>> forceOpened = {};

  List<Row> rows = [];
  void setForceOpen(i, j) {
    if (forceOpened.containsKey(i) && forceOpened[i]!.contains(j)) {
      return;
    }
    if (!forceOpened.containsKey(i)) {
      forceOpened[i] = [];
    }
    forceOpened[i]!.add(j);

    if (!forceOpen.containsKey(i + 1)) {
      forceOpen[i + 1] = [];
    }
    forceOpen[i + 1]!.add(j + 1);
    forceOpen[i + 1]!.add(j);
    forceOpen[i + 1]!.add(j - 1);

    if (!forceOpen.containsKey(i)) {
      forceOpen[i] = [];
    }
    forceOpen[i]!.add(j + 1);
    forceOpen[i]!.add(j);
    forceOpen[i]!.add(j - 1);

    if (!forceOpen.containsKey(i - 1)) {
      forceOpen[i - 1] = [];
    }
    forceOpen[i - 1]!.add(j + 1);
    forceOpen[i - 1]!.add(j);
    forceOpen[i - 1]!.add(j - 1);
    if (i < height - 1 &&
        j < width - 1 &&
        traps[i + 1][j + 1]["openOnZero"] == 1) {
      setForceOpen(i + 1, j + 1);
    }
    if (i < height - 1 && traps[i + 1][j]["openOnZero"] == 1) {
      setForceOpen(i + 1, j);
    }
    if (i < height - 1 && j > 0 && traps[i + 1][j - 1]["openOnZero"] == 1) {
      setForceOpen(i + 1, j - 1);
    }

    if (j < width - 1 && traps[i][j + 1]["openOnZero"] == 1) {
      setForceOpen(i, j + 1);
    }

    if (j > 0 && traps[i][j - 1]["openOnZero"] == 1) {
      setForceOpen(i, j - 1);
    }

    if (i > 0 && j < width - 1 && traps[i - 1][j + 1]["openOnZero"] == 1) {
      setForceOpen(i - 1, j + 1);
    }
    if (i > 0 && traps[i - 1][j]["openOnZero"] == 1) {
      setForceOpen(i - 1, j);
    }
    if (i > 0 && j > 0 && traps[i - 1][j - 1]["openOnZero"] == 1) {
      setForceOpen(i - 1, j - 1);
    }
  }

  void openSurroundOnZero(int i, int j) {
    setState(() {
      setForceOpen(i, j);
    });
  }

  void trapClicked(i, j) {
    // we need to check the tiles with traps, and display the trap on them
    for (i = 0; i < traps.length; i++) {
      for (int j = 0; j < traps[i].length; j++) {
        if (traps[i][j]["hasMine"] == 1) {
          if ((rows[i].children[j] as Tile).rightClicked == false) {
            (rows[i].children[j] as Tile).clicked = true;
          }
        }
      }
    }
    setState(() {});
  }

  void setTraps() {
    traps = [];
    remainingTiles = width * height;
    usedTraps = 0;

    // Logic for specifying mines
    for (int i = 0; i < height; i++) {
      traps.add([]);
      for (int j = 0; j < width; j++) {
        double nextPercentage = (trapsCount - usedTraps) / (remainingTiles);

        bool hasMine =
            nextPercentage > .85 ||
            (Random().nextInt(10)) / 10 < nextPercentage;

        traps[i].add({"hasMine": hasMine ? 1 : 0});
        if (hasMine) {
          usedTraps++;
        }
        remainingTiles--;
      }
    }
    // Logic for building the ui
  }

  @override
  void initState() {
    super.initState();
    setTraps();
  }

  List<Row> getRows() {
    rows = [];
    for (int i = 0; i < height; i++) {
      List<Widget> rowTiles = [];
      for (int j = 0; j < width; j++) {
        int surroundTrapCount = 0;
        if (i > 0) {
          if (traps[i - 1][j]["hasMine"] == 1) {
            surroundTrapCount++;
          }
          if (j < width - 1) {
            if (traps[i - 1][j + 1]["hasMine"] == 1) {
              surroundTrapCount++;
            }
          }
          if (j > 0) {
            if (traps[i - 1][j - 1]["hasMine"] == 1) {
              surroundTrapCount++;
            }
          }
        }
        if (i < height - 1) {
          if (traps[i + 1][j]["hasMine"] == 1) {
            surroundTrapCount++;
          }
          if (j < width - 1) {
            if (traps[i + 1][j + 1]["hasMine"] == 1) {
              surroundTrapCount++;
            }
          }
          if (j > 0) {
            if (traps[i + 1][j - 1]["hasMine"] == 1) {
              surroundTrapCount++;
            }
          }
        }
        if (j > 0) {
          if (traps[i][j - 1]["hasMine"] == 1) {
            surroundTrapCount++;
          }
        }
        if (j < width - 1) {
          if (traps[i][j + 1]["hasMine"] == 1) {
            surroundTrapCount++;
          }
        }

        bool hasMine = traps[i][j]["hasMine"] == 1;
        traps[i][j]["surroundTrapCount"] = surroundTrapCount;
        traps[i][j]["openOnZero"] =
            surroundTrapCount > 0 || traps[i][j]["hasMine"] == 1 ? 0 : 1;
        rowTiles.add(
          Tile(
            hasMine: hasMine,
            surroundTrapCount: surroundTrapCount,
            position: {"x": i, "y": j},
            retryNumber: retryNumber,
            onZeroClick: () {
              openSurroundOnZero(i, j);
            },
            forceOpen: forceOpen.containsKey(i) && forceOpen[i]!.contains(j),
            notifyParentToAutoOpen: () => {autoOpen(i, j)},
            notifyTrapClicked: () => {trapClicked(i, j)},
          ),
        );

        if (forceOpen.containsKey(i) && forceOpen[i]!.contains(j)) {
       
        }
      }

      rows.add(Row(children: rowTiles));
    }
    return rows;
  }

  void autoOpen(int i, int j) {
    Map<int, List<int>> toOpen = {};
    // we need to check how many traps are marked in the surrounding (rightClicked)
    // if enought traps are marked in the surround, we need to setforceOpen on the remaining closed ones (clicked)
    int shouldBeMarked = traps[i][j]["surroundTrapCount"]!;
    int marked = 0;
    toOpen[i - 1] = [];
    toOpen[i] = [];
    toOpen[i + 1] = [];

    if (i > 0) {
      if (j < width - 1) {
        if ((rows[i - 1].children[j + 1] as Tile).rightClicked) {
          marked++;
        } else if (!(rows[i - 1].children[j + 1] as Tile).clicked) {
          // it means this row should be right clicked
          toOpen[i - 1]!.add(j + 1);
        }
      }

      if ((rows[i - 1].children[j] as Tile).rightClicked) {
        marked++;
      } else if (!(rows[i - 1].children[j] as Tile).clicked) {
        toOpen[i - 1]!.add(j);
      }

      if (i > 0) {
        if (j > 0) {
          if ((rows[i - 1].children[j - 1] as Tile).rightClicked) {
            marked++;
          } else if (!(rows[i - 1].children[j - 1] as Tile).clicked) {
            toOpen[i - 1]!.add(j - 1);
          }
        }
      }
    }
    if (j < width - 1) {
      if ((rows[i].children[j + 1] as Tile).rightClicked) {
        marked++;
      } else if (!(rows[i].children[j + 1] as Tile).clicked) {
        toOpen[i]!.add(j + 1);
      }
    }

    if ((rows[i].children[j] as Tile).rightClicked) {
      marked++;
    } else if (!(rows[i].children[j] as Tile).clicked) {
      toOpen[i]!.add(j);
    }
    if (j > 0) {
      if ((rows[i].children[j - 1] as Tile).rightClicked) {
        marked++;
      } else if (!(rows[i].children[j - 1] as Tile).clicked) {
        toOpen[i]!.add(j - 1);
      }
    }

    if (i < height - 1) {
      if (j < width - 1) {
        if ((rows[i + 1].children[j + 1] as Tile).rightClicked) {
          marked++;
        } else if (!(rows[i + 1].children[j + 1] as Tile).clicked) {
          toOpen[i + 1]!.add(j + 1);
        }
      }
      if ((rows[i + 1].children[j] as Tile).rightClicked) {
        marked++;
      } else if (!(rows[i + 1].children[j] as Tile).clicked) {
        toOpen[i + 1]!.add(j);
      }
      if (j > 0) {
        if ((rows[i + 1].children[j - 1] as Tile).rightClicked) {
          marked++;
        } else if (!(rows[i + 1].children[j - 1] as Tile).clicked) {
          toOpen[i + 1]!.add(j - 1);
        }
      }
    }

    if (marked == shouldBeMarked) {
      // here we need to open the surrounding closed tiles
      toOpen.forEach((i, value) {
        // key is the i
        // value is an array
        value.forEach((j) {
          Tile activeTile = (rows[i].children[j] as Tile);
          activeTile.clicked = true;
          if (activeTile.surroundTrapCount == 0) {
            openSurroundOnZero(i, j);
          }
        });
      });
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed:
            () => {
              setState(() {
                rows = [];
                forceOpened = {};
                forceOpen = {};
                retryNumber++;
                setTraps();
              }),
            },
      ),
      appBar: AppBar(title: Text("Avoid the mines!")),
      body: Center(child: Column(children: getRows())),
    );
  }
}
