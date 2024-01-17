package com.example.testing_application

import android.annotation.SuppressLint
import android.bluetooth.BluetoothManager
import android.content.Context
import android.content.IntentFilter
import android.content.pm.PackageManager
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import toBluetoothDeviceDomain
import java.util.jar.Manifest

@SuppressLint("MissingPermission")
class AndroidBluetoothController (
        private val context: Context
        ): BluetoothController{

    private val bluetoothManager by lazy{
        context.getSystemService(BluetoothManager::class.java)
    }

    private val bluetoothAdapter by lazy{
        bluetoothManager?.adapter
    }

    private val _scannedDevices = MutableStateFlow<List<BluetoothDeviceDomain>>(emptyList())
    override val scannedDevices: StateFlow<List<BluetoothDeviceDomain>>
        get() = _scannedDevices.asStateFlow()

    private val _pairedDevices = MutableStateFlow<List<BluetoothDeviceDomain>>(emptyList())
    override val pairedDevices: StateFlow<List<BluetoothDeviceDomain>>
        get() = _pairedDevices.asStateFlow()

    private val foundDeviceReceiver = FoundDeviceReceiver{
        device -> _scannedDevices.update { devices ->
            val newDevice = device.toBluetoothDeviceDomain()
        if(newDevice in devices) devices else devices + newDevice
    }
    }

    init{
        updatePairedDevices()
    }

    override fun startDiscovery() {
        if(!hasPermission(android.Manifest.permission.BLUETOOTH_SCAN)){
            println('S');
            return
        }
        println('F');

        context.registerReceiver(
            foundDeviceReceiver,
            IntentFilter(android.bluetooth.BluetoothDevice.ACTION_FOUND)
        )

        updatePairedDevices()
        bluetoothAdapter?.startDiscovery()
    }

    override fun stopDiscovery() {
        if(!hasPermission(android.Manifest.permission.BLUETOOTH_CONNECT)){
            return
        }

        bluetoothAdapter?.cancelDiscovery()
    }

    override fun release() {
        context.unregisterReceiver(
            foundDeviceReceiver
        )
    }

    fun getScannedDevices(): List<BluetoothDevice> {
        return _scannedDevices.value
    }


    private fun updatePairedDevices(){
        if(!hasPermission(android.Manifest.permission.BLUETOOTH_CONNECT)){
            return
        }
        bluetoothAdapter?.bondedDevices?.map{
            it.toBluetoothDeviceDomain() }
            ?.also { devices ->
            _pairedDevices.update { devices } }
    }

    fun hasPermission(permission: String): Boolean{
        return context.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED
    }
}