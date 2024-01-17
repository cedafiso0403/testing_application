package com.example.testing_application

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.*


class MainActivity: FlutterActivity() {


    private val CHANNEL = "testing_channel"

    private lateinit var bluetoothController: AndroidBluetoothController

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Initialize the Bluetooth controller
        bluetoothController = AndroidBluetoothController(context)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startBluetoothDiscovery" -> {
                    bluetoothController.startDiscovery()
                    result.success(null)
                }
                "stopBluetoothDiscovery" -> {
                    bluetoothController.stopDiscovery()
                    result.success(null)
                }
                "getScannedDevices" -> {
                    var hashMap : HashMap<String?, String>
                            = HashMap<String?, String> ()
                    bluetoothController.scannedDevices.value.map {
                        device ->  hashMap.put(device.name, device.address)
                    }
                    println("Que monda es esto:$hashMap \n")

                    result.success(hashMap)
                }
                "statePermission" ->{
                    val devices = bluetoothController.hasPermission(android.Manifest.permission.BLUETOOTH_CONNECT)
                    result.success(devices)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        // Release resources when the activity is destroyed
        bluetoothController.release()
    }


}


