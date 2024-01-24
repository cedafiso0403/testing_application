import 'dart:math';

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
  final EventChannel eventChannelConnected =
      EventChannel('on_device_connected');
  List<Map<String?, String>> devicesScanned = [];
  List<Map<String?, String>> devicesConnected = [];

  void startBluetoothDiscovery() async {
    try {
      final bool? result =
          await platformChannel.invokeMethod('startBluetoothDiscovery');
      print('Result from Native: $result');
    } on PlatformException catch (e) {
      print('Error: ${e.message}');
    }
  }

  void stopBluetoothDiscovery() async {
    try {
      final bool? result =
          await platformChannel.invokeMethod('stopBluetoothDiscovery');
      print('Result from Native: $result');
    } on PlatformException catch (e) {
      print('Error: ${e.message}');
    }
  }

  void disconnectAllDevices() async {
    try {
      final bool? result =
          await platformChannel.invokeMethod('disconnectAllDevices');
      print('Result from Native: $result');
    } on PlatformException catch (e) {
      print('Error: ${e.message}');
    }
  }

  void startOneTimeJob() async {
    try {
      final dynamic result = await platformChannel.invokeMethod('startJob');
      print('Result from Native Scanned: ${result.toString()}');
    } on PlatformException catch (e) {
      print('Error: ${e.message}');
    }
  }

  void startPeriodicJob() async {
    try {
      final dynamic result =
          await platformChannel.invokeMethod('startPeriodicTimeJob');
      print('Result from Native Scanned: ${result.toString()}');
    } on PlatformException catch (e) {
      print('Error: ${e.message}');
    }
  }

  Stream<String> streamConnectedDevices() {
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
    final streamScannedDevices = eventChannel.receiveBroadcastStream().map(
      (event) {
        return event;
      },
    ).listen((event) {
      final element = devicesScanned.indexWhere((element) {
        if (element['name'] == event.toString()) {
          return true;
        }
        return false;
      });
      if (element != -1) {
        return;
      }
      setState(() {
        devicesScanned.add({'name': event.toString(), 'address': ''});
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My app'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  startBluetoothDiscovery();
                },
                child: const Text('Start Discovery'),
              ),
              ElevatedButton(
                onPressed: () {
                  stopBluetoothDiscovery();
                },
                child: const Text('Stop Discovery'),
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.contain,
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    disconnectAllDevices();
                  },
                  child: const Text('Disconnect All Devices'),
                ),
                ElevatedButton(
                  onPressed: () {
                    startOneTimeJob();
                  },
                  child: const Text('Start One Time Job'),
                ),
                ElevatedButton(
                  onPressed: () {
                    startPeriodicJob();
                  },
                  child: const Text('Start Periodic Job'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: devicesScanned.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(devicesScanned[index]['name']!),
                  subtitle: Text(devicesScanned[index]['address']!),
                );
              },
            ),
          ),
        ],
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
