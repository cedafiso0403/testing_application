package com.example.testing_application

import android.annotation.SuppressLint
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothGattCallback
import android.bluetooth.BluetoothGattCharacteristic
import android.content.Context
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.update

class BleConnector(
    private val context: Context,
    private val device: BluetoothDevice,
    private val _scannedDevices: MutableStateFlow<List<BluetoothDevice>>,
    private val _connectedDevices: MutableStateFlow<List<BleConnector>>
) {

    private var bluetoothGatt: BluetoothGatt? = null

    @SuppressLint("MissingPermission")
    fun connect() {
        try {
            bluetoothGatt = device.connectGatt(context, true, gattCallback, 2)
        } catch (e: Exception) {
            println("$e")
        }

    }

    @SuppressLint("MissingPermission")
    fun disconnect() {
        bluetoothGatt?.disconnect()
    }

    fun getDeviceInfo(): BluetoothDevice {
        return device
    }

    private val gattCallback = object : BluetoothGattCallback() {
        @SuppressLint("MissingPermission")
        override fun onConnectionStateChange(
            gatt: BluetoothGatt?, status: Int, newState: Int
        ) {
            if (newState == BluetoothGatt.STATE_CONNECTED && status == BluetoothGatt.GATT_SUCCESS) {
                _connectedDevices.update { device ->
                    if (!device.contains(this@BleConnector)) (device + this@BleConnector) else device
                }
                _scannedDevices.update { devices ->
                    if (devices.contains(device)) (devices - device) else devices
                }
                println("Kotlin: Device connected ${device.name} ${device.address}")
                gatt?.discoverServices()
            } else if (newState == BluetoothGatt.STATE_DISCONNECTED) {
                _connectedDevices.update { device ->
                    if (device.contains(this@BleConnector)) (device - this@BleConnector) else device
                }
                println("Kotlin: Device disconnected ${device.name} ${device.address}")
            }



        }

        override fun onServicesDiscovered(gatt: BluetoothGatt, status: Int) {
            if (status == BluetoothGatt.GATT_SUCCESS) {
                // Services discovered, you can now work with characteristics
                val services = gatt.services

                for (service in services) {
                    val serviceUUID: String = service.uuid.toString()
                    println("Service UUID: $serviceUUID")

                    // Optionally, you can iterate through the characteristics of each service
                    val characteristics: List<BluetoothGattCharacteristic> = service.characteristics
                    for (characteristic in characteristics) {
                        val characteristicUUID: String = characteristic.uuid.toString()
                        println("  Characteristic UUID: $characteristicUUID")
                    }
                }


            }
        }
    }

}