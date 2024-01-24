package com.example.testing_application

import android.annotation.SuppressLint
import android.bluetooth.BluetoothManager
import android.bluetooth.le.ScanFilter
import android.bluetooth.le.ScanSettings
import android.content.Context
import android.content.pm.PackageManager
import kotlinx.coroutines.flow.*

@SuppressLint("MissingPermission")
class AndroidBluetoothController(
    private val context: Context
) : BluetoothController {

    private val bluetoothManager by lazy {
        context.getSystemService(BluetoothManager::class.java)
    }

    private val bluetoothAdapter by lazy {
        bluetoothManager?.adapter?.bluetoothLeScanner
    }


    private val _scannedDevices = MutableStateFlow<List<android.bluetooth.BluetoothDevice>>(emptyList())
    override val scannedDevices: StateFlow<List<android.bluetooth.BluetoothDevice>>
        get() = _scannedDevices.asStateFlow()


    private val _connectedDevices = MutableStateFlow<List<BleConnector>>(emptyList())
    override val connectedDevices: StateFlow<List<BleConnector>>
        get() = _connectedDevices.asStateFlow()

    private val scanCallback = CallBackController(_scannedDevices)

    private val connectionManager = ConnectionManager(context, _scannedDevices, bluetoothAdapter!!)


    init {

    }

    override fun startDiscovery() {
        if (!hasPermission(android.Manifest.permission.BLUETOOTH_SCAN)) {
            return
        }
        val filters = mutableListOf<ScanFilter>()

        val deviceName = "FSRB6A"
        val scanFilterByName = ScanFilter.Builder()
            .setDeviceName(deviceName)
            .build()
        filters.add(scanFilterByName)

        val scanSettings =
            ScanSettings.Builder().setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY).build()


        bluetoothAdapter?.flushPendingScanResults((scanCallback))




        bluetoothAdapter?.startScan(
            filters, scanSettings, scanCallback
        )

    }

    override fun stopDiscovery() {
        if (!hasPermission(android.Manifest.permission.BLUETOOTH_CONNECT)) {
            return
        }
        bluetoothAdapter?.stopScan(scanCallback)

    }


    fun disconnectAll() {
        connectionManager.disconnectAll()
    }


    fun hasPermission(permission: String): Boolean {
        return context.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED
    }

}