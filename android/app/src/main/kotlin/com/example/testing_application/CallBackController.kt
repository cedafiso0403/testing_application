package com.example.testing_application

import android.annotation.SuppressLint
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanResult
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.update

@SuppressLint("MissingPermission")
class CallBackController(
    private val _scannedDevices: MutableStateFlow<List<android.bluetooth.BluetoothDevice>>
) : ScanCallback() {


    override fun onScanResult(callbackType: Int, result: ScanResult?) {
        super.onScanResult(callbackType, result)
        println("Kotlin: Had result")
        // Handle the scan result here
        result?.device?.let {
            println("Kotlin: ${it.name} ${it.address}")
            _scannedDevices.update { devices ->
                if (!devices.contains(it)) (devices + it) else devices
                // Process the device information
            }
        }
    }

    override fun onScanFailed(errorCode: Int) {
        super.onScanFailed(errorCode)
        println("Kotlin: Scan failed with error code $errorCode")
    }
}