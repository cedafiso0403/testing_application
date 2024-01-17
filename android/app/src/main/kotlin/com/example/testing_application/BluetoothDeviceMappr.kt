
import android.annotation.SuppressLint
import android.bluetooth.BluetoothDevice
import com.example.testing_application.BluetoothDeviceDomain

@SuppressLint("MissingPermission")
fun BluetoothDevice.toBluetoothDeviceDomain() : BluetoothDeviceDomain{
    return BluetoothDeviceDomain(
        name = name,
        address = address
    )
}