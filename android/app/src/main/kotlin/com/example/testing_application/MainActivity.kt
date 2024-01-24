package com.example.testing_application

import android.annotation.SuppressLint
import android.os.Handler
import android.os.Looper
import androidx.appcompat.app.AppCompatActivity
import androidx.work.*
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*
import java.util.*
import java.util.concurrent.TimeUnit


class MainActivity: FlutterActivity() {


    private val CHANNEL = "testing_channel"
    private val EVENTCHANNEL = "on_device_found"
    private val EVENTCHANNELCONNECTED = "on_device_connected"

    lateinit var bluetoothController: AndroidBluetoothController

    override fun onStart(){
        super.onStart()
    }

    @SuppressLint("MissingPermission")
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Initialize the Bluetooth controller
        bluetoothController = AndroidBluetoothController(context)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENTCHANNEL).setStreamHandler(
            OnDeviceFoundHandler(bluetoothController)
        )

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENTCHANNELCONNECTED).setStreamHandler(
            OnDeviceConnected(bluetoothController)
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
                "disconnectAllDevices" -> {
                    bluetoothController.disconnectAll()
                    result.success(null)
                }
                "startPeriodicTimeJob" ->{
                    try{
                        myPeriodicWork()
                        result.success(true)
                    } catch (e: Exception){
                        result.success(false)
                    }
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
    }

//    private fun myOneTimeWork(){
//        val constraint = Constraints.Builder()
//            .setRequiredNetworkType(NetworkType.NOT_REQUIRED)
//            .setRequiresCharging(true)
//            .build()
//
//        val myWorkRequest:WorkRequest = OneTimeWorkRequest.Builder(MyWorker::class.java)
//            .setConstraints(constraint)
//            .build()
//
//        WorkManager.getInstance(this).enqueue(myWorkRequest)
//
//    }

    private fun myPeriodicWork(){
        val constraint = Constraints.Builder()
            .setRequiredNetworkType(NetworkType.NOT_REQUIRED)
            .build()

        val myWorkRequest:PeriodicWorkRequest = PeriodicWorkRequest.Builder(MyWorker::class.java, 15, TimeUnit.MINUTES)
            .setConstraints(constraint)
            .addTag("my_id")
            .build()

        WorkManager.getInstance(this).enqueueUniquePeriodicWork("my_id", ExistingPeriodicWorkPolicy.KEEP, myWorkRequest)
    }

    class OnDeviceFoundHandler(private val bluetoothController: AndroidBluetoothController) : EventChannel.StreamHandler {

        // Declare our eventSink later it will be initialized
        private var eventSink: EventChannel.EventSink? = null

        @SuppressLint("SimpleDateFormat", "MissingPermission")
        override fun onListen(p0: Any?, sink: EventChannel.EventSink) {
            eventSink = sink
            val customScope = CoroutineScope(Dispatchers.Default + Job())
            var hashMap : HashMap<String?, String>
                    = HashMap<String?, String> ()
            val _state = MutableStateFlow(DevicesState())
            val state = combine(bluetoothController.scannedDevices, _state) { scannedDevices, state ->
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
                    delay(1000)
                }
            }


        }

        override fun onCancel(p0: Any?) {
            eventSink = null
        }
    }

    class OnDeviceConnected(private val bluetoothController: AndroidBluetoothController) : EventChannel.StreamHandler {

        // Declare our eventSink later it will be initialized
        private var eventSink: EventChannel.EventSink? = null

        @SuppressLint("SimpleDateFormat", "MissingPermission")
        override fun onListen(p0: Any?, sink: EventChannel.EventSink) {
            eventSink = sink
            val customScope = CoroutineScope(Dispatchers.Default + Job())
            var hashMap : HashMap<String?, String>
                    = HashMap<String?, String> ()
            val _state = MutableStateFlow(DevicesConnectedState())
            val state = combine(bluetoothController.connectedDevices, _state) { connectedDevices, state ->
                state.copy(
                    connectedDevices = connectedDevices
                )
            }.stateIn(
                scope = customScope,
                started = SharingStarted.WhileSubscribed(5000),
                initialValue = _state.value
            )

            val job = customScope.launch {
                state.collect { devicesConnected ->
                    devicesConnected.connectedDevices.forEach { device ->
                        hashMap[device.getDeviceInfo().name] = device.getDeviceInfo().address
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
        val scannedDevices: List<android.bluetooth.BluetoothDevice> = emptyList()
    )

    data class DevicesConnectedState(
        val connectedDevices: List<BleConnector> = emptyList()
    )
}




