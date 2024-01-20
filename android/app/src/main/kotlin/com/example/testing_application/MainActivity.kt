package com.example.testing_application

import android.annotation.SuppressLint
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*
import java.util.*


class MainActivity: FlutterActivity() {


    private val CHANNEL = "testing_channel"
    private val EVENTCHANNEL = "on_device_found"


    lateinit var bluetoothController: AndroidBluetoothController

    @SuppressLint("MissingPermission")
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Initialize the Bluetooth controller
        bluetoothController = AndroidBluetoothController(context)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENTCHANNEL).setStreamHandler(
            OnDeviceFoundHandler(bluetoothController)
        )

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

    override fun onResume() {
        super.onResume()
    }

    override fun onDestroy() {
        super.onDestroy()
        // Release resources when the activity is destroyed
        bluetoothController.release()
    }

    class OnDeviceFoundHandler(private val bluetoothController: AndroidBluetoothController) : EventChannel.StreamHandler {

        // Declare our eventSink later it will be initialized
        private var eventSink: EventChannel.EventSink? = null

        @SuppressLint("SimpleDateFormat")
        override fun onListen(p0: Any?, sink: EventChannel.EventSink) {
            println("CALLED")
            eventSink = sink
            val customScope = CoroutineScope(Dispatchers.Default + Job())
            var hashMap : HashMap<String?, String>
                    = HashMap<String?, String> ()
            val _state = MutableStateFlow(DevicesState())
            val state = combine(bluetoothController.scannedDevices, _state) { scannedDevices, state ->
                println("MONDAAAAA")
                state.copy(
                    scannedDevices = scannedDevices
                )
            }.stateIn(
                scope = customScope,
                started = SharingStarted.WhileSubscribed(5000),
                initialValue = _state.value
            )

            val job = customScope.launch {
                state.collect { scannedDeviceState ->
                    scannedDeviceState.scannedDevices.forEach { device ->
                        hashMap[device.name] = device.address
                    }
                    withContext(Dispatchers.Main) {
                        eventSink?.success(hashMap)
                    }
                }
            }

        }

        override fun onCancel(p0: Any?) {
            eventSink = null
        }
    }

    data class DevicesState(
        val scannedDevices: List<BluetoothDevice> = emptyList()
    )
}




