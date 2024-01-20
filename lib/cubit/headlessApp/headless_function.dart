import 'dart:io';
import 'dart:isolate';

class HeadLessApp {
  SendPort? sendPort;
  dynamic message;

  void startHeadlessTask(Function startTime, Function currentTime) async {
    final ReceivePort receivePort = ReceivePort();
    final isolate = await Isolate.spawn(
      _isolateEntryPoint,
      receivePort.sendPort,
    );

    startTime(DateTime.now());

    receivePort.listen(
      (message) {
        sendPort = message is SendPort ? message : null;
        print('Headless Received message: $message');
        if (message is DateTime) {
          print("Headless Received time: $message");
          currentTime(message);
        }
      },
    );

    sendPort?.send("Headless Hello!");
  }

  void sendInfoToHeadlessTask(dynamic message) {
    print("Headless Sending message to headless isolate: $message");
    sendPort?.send(message);
  }

  // This function runs in the separate isolate
  static void _isolateEntryPoint(
    SendPort sendPort,
  ) {
    final ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    receivePort.listen(
      (message) {
        print("Headless Received message in headless isolate: $message");
        // Call your headless task function here
        myHeadlessTask(sendPort);
      },
    );
  }

  static void myHeadlessTask(SendPort sendPort) {
    // Your background logic here
    while (true) {
      print("Headless Time now: ${DateTime.now()}");
      sendPort.send(DateTime.now());
      sleep(
        const Duration(seconds: 5),
      );
    }
    ;
  }
}
