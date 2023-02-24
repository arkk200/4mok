import 'package:flutter/material.dart';
import 'package:frontend/screens/main_screen.dart';
import 'package:socket_io_client/socket_io_client.dart';

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
  // late BuildContext context;
  late final Socket socket;
  late int posX;
  late int posY;
  late String order;
  List<Map<String, int>> setMokLog = [], placeMokLog = [];

  void setSocketEvent() {
    socket.on('setMok', (data) {
      if (data == null) return;
      // if (mounted) {
      setState(() {
        setMokLog.add({
          'x': data['x'],
          'y': data['y'],
        });
      });
      // }
    });
    socket.on('placeMok', (data) {
      if (data == null) return;
      if (mounted) {
        setState(() {
          order = data['order'];
          placeMokLog.add({
            'x': data['x'],
            'y': data['y'],
          });
        });
      }
    });
    socket.on('gameOver', (data) {
      debugPrint("line 55: Is it mounted? $mounted");
      if (mounted) {
        setState(() {
          if (data['isWin'] != null) {
            handleShowGameOverAlert(data['isWin']);
          }
          if (data['oppResigned'] == true) {
            handleShowOppResignedAlert();
          }
        });
      }
    });
  }

  @override
  void initState() {
    debugPrint("line 71: Is it mounted? $mounted");
    super.initState();
    socket = widget.socket;
    order = widget.firstOrder;
    setSocketEvent();
  }

  void handleShowGameOverAlert(isWin) {
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

  void handleShowOppResignedAlert() {
    showAlert(
      AlertDialog(
        title: const Text("Opponent resigned this game"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              handleShowGameOverAlert(true);
            },
            child: const Text("Ok"),
          ),
        ],
      ),
    );
  }

  void onSetMok() {
    socket.emit('setMok', {
      'x': posX,
      'y': posY,
      'roomId': widget.roomId,
    });
  }

  void onPlaceMok() {
    socket.emit('placeMok', {
      'x': posX,
      'y': posY,
      'order': order,
      'playersId': widget.playersInfo.map((info) => info['id']).toList(),
      'roomId': widget.roomId,
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("setMok log"),
          Column(
            children: [
              for (var value in setMokLog) Text("${value['x']}, ${value['y']}")
            ],
          ),
          const Text("placeMok log"),
          Column(
            children: [
              for (var value in placeMokLog)
                Text("${value['x']}, ${value['y']}")
            ],
          ),
          Text(socket.id == order ? "Your turn" : "None"),
          (socket.id == order
              ? Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "mok pos x",
                      ),
                      onChanged: (value) {
                        posX = int.parse(value);
                        debugPrint("$posX");
                      },
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "mok pos y",
                      ),
                      onChanged: (value) {
                        posY = int.parse(value);
                        debugPrint("$posY");
                      },
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                      ),
                      onPressed: onSetMok,
                      child: const Text("handle set mok"),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                      ),
                      onPressed: onPlaceMok,
                      child: const Text("haneld place mok"),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                      ),
                      onPressed: handleTimeOut,
                      child: const Text("handle time out"),
                    ),
                  ],
                )
              : const Text("Not your turn")),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
            ),
            onPressed: () => showAlert(
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
            child: const Text("resign"),
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
