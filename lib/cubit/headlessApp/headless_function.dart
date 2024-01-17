import 'dart:isolate';

class HeadLessApp {
  SendPort? sendPort;

  dynamic message;

  void startHeadlessTask() async {
    final ReceivePort receivePort = ReceivePort();
    final isolate = await Isolate.spawn(
      _isolateEntryPoint,
      receivePort.sendPort,
    );

    receivePort.listen(
      (message) {
        sendPort = message is SendPort ? message : null;
        print('Received message: $message');
      },
    );

    sendPort?.send("Hello!");
  }

  void sendInfoToHeadlessTask(dynamic message) {
    sendPort?.send(message);
  }

  // This function runs in the separate isolate
  static void _isolateEntryPoint(SendPort sendPort) {
    final ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    receivePort.listen((message) {
      print("Received message in headless isolate: $message");
      sendPort.send("Hello from headless isolate!");
      // Call your headless task function here
      myHeadlessTask();
    });
  }

  static void myHeadlessTask() {
    // Your background logic here
    print("Headless task is running...");
  }
}
