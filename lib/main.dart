import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:testing_application/cubit/headlessApp/headless_function.dart';
import 'package:testing_application/cubit/test_cubit.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationDocumentsDirectory(),
  );
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TestCubit()..start(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late HeadLessApp headLessApp;

  final MethodChannel platformChannel = MethodChannel('testing_channel');
  final EventChannel eventChannel = EventChannel('on_device_found');

  void startBluetoothDiscovery() async {
    try {
      final bool? result =
          await platformChannel.invokeMethod('startBluetoothDiscovery');
      print('Result from Native: $result');
    } on PlatformException catch (e) {
      print('Error: ${e.message}');
    }
  }

  void getScannedDevices() async {
    try {
      final dynamic result =
          await platformChannel.invokeMethod('getScannedDevices');
      print('Result from Native Scanned: ${result.toString()}');
    } on PlatformException catch (e) {
      print('Error: ${e.message}');
    }
  }

  void statePermission() async {
    try {
      final dynamic result =
          await platformChannel.invokeMethod('statePermission');
      print('Result from Native: ${result.toString()}');
    } on PlatformException catch (e) {
      print('Error: ${e.message}');
    }
  }

  Stream<String> streamTimeFromNative() {
    return eventChannel.receiveBroadcastStream().map(
      (event) {
        print(event.toString());
        return event.toString();
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    startBluetoothDiscovery();
    streamTimeFromNative().listen((event) {
      print("Ayudame jesus${event}");
    });
    headLessApp = HeadLessApp()
      ..startHeadlessTask(
        context.read<TestCubit>().setStartTime,
        context.read<TestCubit>().setCurrentTime,
      );
    return Scaffold(
      appBar: AppBar(
        title: const Text('My app'),
      ),
      body: Center(
        child: BlocBuilder<TestCubit, TestState>(
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('${state.count}'),
                Text('${state.startTime}'),
                Text('${state.currentTime}'),
                ElevatedButton(
                  onPressed: () {
                    statePermission();
                    getScannedDevices();
                  },
                  child: const Text('Start'),
                ),
                ElevatedButton(
                  onPressed: () {
                    requestBluetoothPermission();
                  },
                  child: const Text('Start'),
                ),
                ElevatedButton(
                  onPressed: () {
                    startBluetoothDiscovery();
                  },
                  child: const Text('Start 3'),
                ),
                ElevatedButton(
                  onPressed: () {
                    headLessApp.sendInfoToHeadlessTask("QUE MIERDA");
                  },
                  child: const Text('Start Headless'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> requestBluetoothPermission() async {
    // Request Bluetooth permissions
    var status = await Permission.bluetooth.request();

    if (status == PermissionStatus.granted) {
      // Bluetooth permission granted, you can proceed with Bluetooth operations
      print('Bluetooth permission granted');
    } else {
      // Bluetooth permission denied
      print('Bluetooth permission denied');
    }
  }
}

class BluetoothDeviceData {
  BluetoothDeviceData(
    String? name,
    String address,
  ) : super();
}
