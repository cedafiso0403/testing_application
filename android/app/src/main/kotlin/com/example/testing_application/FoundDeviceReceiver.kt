package com.example.testing_application

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

class FoundDeviceReceiver(
    private val onDeviceFound: (android.bluetooth.BluetoothDevice) -> Unit
) : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        when(intent?.action){
            android.bluetooth.BluetoothDevice.ACTION_FOUND -> {
                val device = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    println("First if \n")
                    intent?.getParcelableExtra(
                        android.bluetooth.BluetoothDevice.EXTRA_NAME,
                        android.bluetooth.BluetoothDevice::class.java
                    )
                } else {
                    println("Segundo if \n")
                    intent.getParcelableExtra(
                        android.bluetooth.BluetoothDevice.EXTRA_DEVICE,

                    )
                }
                println("No error \n")

                device?.let(onDeviceFound)
            }
        }
    }
}