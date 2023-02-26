import 'package:flutter/material.dart';
import 'package:frontend/screens/main_screen.dart';
import 'package:frontend/widgets/board_widget.dart';
import 'package:socket_io_client/socket_io_client.dart';

GlobalKey<BoardState> globalKey = GlobalKey();

class GameScreen extends StatefulWidget {
  final Socket socket;
  final String roomId;
  final String firstOrder;
  final List playersInfo;

  const GameScreen.fromMainScreen({
    super.key,
    required this.socket,
    required this.roomId,
    required this.firstOrder,
    required this.playersInfo,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final Socket socket;
  late int posY;
  late String order;
  int? setMokPosY;
  List<List<String>> board = [[], [], [], [], [], [], []];

  void setSocketEvent() {
    socket.on('setMok', (data) {
      if (mounted) {
        setState(() {
          setMokPosY = data['y'];
        });
      }
    });
    socket.on('placeMok', (data) {
      if (mounted) {
        setState(() {
          order = data['order'];
          board = (data['board'] as List)
              .map(
                (column) => (column as List)
                    .map(
                      (cell) => cell as String,
                    )
                    .toList(),
              )
              .toList();
        });
        globalKey.currentState?.handlePlaceMok();
      }
    });
    socket.on('gameOver', (data) {
      if (mounted) {
        setState(() {
          if (data['isWin'] != null) {
            handleMatchOverAlert(data['isWin']);
          }
          if (data['oppResigned'] == true) {
            handleOppResignedAlert();
          }
          if (data['isDraw'] != null) {
            handleDrawAlert();
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    socket = widget.socket;
    order = widget.firstOrder;
    setSocketEvent();
  }

  void handleMatchOverAlert(isWin) {
    showAlert(
      AlertDialog(
        title: Text(isWin == true ? "You win" : "You lose"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      MainScreen.fromGameScreen(
                    socket: socket,
                  ),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
            child: const Text("Ok"),
          ),
        ],
      ),
    );
  }

  void handleDrawAlert() {
    showAlert(
      AlertDialog(
        title: const Text("Draw"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      MainScreen.fromGameScreen(
                    socket: socket,
                  ),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
            child: const Text("Ok"),
          ),
        ],
      ),
    );
  }

  void handleOppResignedAlert() {
    showAlert(
      AlertDialog(
        title: const Text("Opponent resigned this game"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              handleMatchOverAlert(true);
            },
            child: const Text("Ok"),
          ),
        ],
      ),
    );
  }

  void onSetMok() {
    setState(() {
      socket.emit('setMok', {
        'y': posY,
        'roomId': widget.roomId,
      });
    });
  }

  void onPlaceMok() {
    if (setMokPosY == null) return;
    setState(() {
      socket.emit('placeMok', {
        'y': posY,
        'order': order,
        'playersId': widget.playersInfo.map((info) => info['id']).toList(),
        'roomId': widget.roomId,
        'board': board,
      });
    });
  }

  void handleTimeOut() {
    socket.emit('timeOut', {
      'playerId': socket.id,
      'playersId': widget.playersInfo.map((info) => info['id']).toList(),
      'roomId': widget.roomId,
    });
  }

  void handleResignClick() {
    socket.emit('resign', {
      'playerId': socket.id,
      'playersId': widget.playersInfo.map((info) => info['id']).toList(),
      'roomId': widget.roomId,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 115,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  socket.id == order ? "Your turn" : "Opponent turn",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Board(
            key: globalKey,
            setPos: (int y) {
              if (socket.id != order) return;
              setState(() {
                posY = y;
                onSetMok();
              });
            },
            setMokPosY: setMokPosY,
            initProperty: () => setState(() {
              setMokPosY = null;
            }),
          ),
          SizedBox(
            width: 115,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  child: Container(
                    width: 88,
                    height: 125,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        width: 4,
                        color: const Color(0xFF0066FF),
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.outlined_flag_rounded,
                          size: 50,
                          color: Color(0xFF0066FF),
                        ),
                        Text(
                          "Resign",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF0066FF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () => showAlert(
                    AlertDialog(
                      title: const Text("Are you sure to resign this game?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            handleResignClick();
                          },
                          child: const Text("Ok"),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                InkWell(
                    child: Container(
                        width: 88,
                        height: 125,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            width: 4,
                            color: socket.id == order
                                ? const Color(0xFF42FF00)
                                : Colors.grey.shade600,
                          ),
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 50,
                          color: socket.id == order
                              ? const Color(0xFF42FF00)
                              : Colors.grey.shade600,
                        )),
                    onTap: () {
                      if (socket.id == order) onPlaceMok();
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showAlert(alertWidget) {
    showDialog(
      context: context,
      builder: (context) => alertWidget,
      barrierDismissible: false,
    );
  }
}
