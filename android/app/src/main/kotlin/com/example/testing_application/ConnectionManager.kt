package com.example.testing_application

import android.annotation.SuppressLint
import android.bluetooth.BluetoothDevice
import android.bluetooth.le.BluetoothLeScanner
import android.content.Context
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

class ConnectionManager(
    private val context: Context,
    private val _scannedDevices: MutableStateFlow<List<BluetoothDevice>>,
    private val bluetoothAdapter: BluetoothLeScanner,
) {

    private val _connectedDevices = MutableStateFlow<List<BleConnector>>(emptyList())
    val connectedDevices: StateFlow<List<BleConnector>>
        get() = _connectedDevices.asStateFlow()
    init {
        // Launch a coroutine to collect emitted values from bleConnections
        GlobalScope.launch {
            _scannedDevices.collect { connectors ->
                // Handle each emitted value (List<BleConnector>) here
                handleBleConnectors(connectors)
            }
        }
    }

    @SuppressLint("MissingPermission")
    private fun handleBleConnectors(connectors: List<BluetoothDevice>) {
        // Add your logic to handle the emitted list of BleConnectors
        // For example, you might iterate through the list and perform actions
        for (connector in connectors) {
            if (!getConnectedDevices().contains(connector)) {
                // Connect to the device
                val bleConnector = BleConnector(context, connector, _scannedDevices, _connectedDevices)
                bleConnector.connect()
                _connectedDevices.update { device ->
                    if (!device.contains(bleConnector)) (device + bleConnector) else device
                }
            }
        }
    }

    fun disconnectAll() {
        _connectedDevices.value.forEach { connection ->
            connection.disconnect()
        }
    }

    private fun getConnectedDevices(): List<BluetoothDevice> {
        return connectedDevices.value.map { device ->
            device.getDeviceInfo()
        }
    }

}