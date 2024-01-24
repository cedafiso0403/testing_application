package com.example.testing_application


import android.bluetooth.BluetoothDevice
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.StateFlow

interface BluetoothController{
    val scannedDevices: StateFlow<List<android.bluetooth.BluetoothDevice>>
    val connectedDevices: StateFlow<List<BleConnector>>


    fun startDiscovery()
    fun stopDiscovery()

}