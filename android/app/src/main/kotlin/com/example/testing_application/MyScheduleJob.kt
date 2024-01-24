package com.example.testing_application

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.PendingIntent.FLAG_IMMUTABLE
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationManagerCompat
import androidx.work.Worker
import androidx.work.WorkerParameters
import io.flutter.Log
import java.lang.reflect.Parameter


class MyWorker(context: Context, workerParameter: WorkerParameters)  : Worker(context,workerParameter) {

    companion object{
        const val  CHANNEL_ID = "channel_id"
        const val NOTIFICATION = 1
    }

    override fun doWork(): Result {
        Log.d("doWork", "dpWork: Success function called")
        Thread.sleep(10000)
        showNotification()
        return Result.success()
    }

    private fun showNotification(){
        val intent = Intent(applicationContext,MainActivity::class.java).apply{
            var flaggs = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }


        val pendingIntent = PendingIntent.getActivity(applicationContext, 0, intent, FLAG_IMMUTABLE)

        val notification = Notification.Builder(applicationContext, CHANNEL_ID)
            .setSmallIcon(R.drawable.launch_background)
            .setContentTitle("new mask")
            .setContentText("Subscribe Channel")
            .setPriority(Notification.PRIORITY_MAX)
            .setContentIntent(pendingIntent)

        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            val channelName = "channel name"
            val channelDescription = "channel description"
            val channelImportance = NotificationManager.IMPORTANCE_HIGH

            val channel = NotificationChannel(CHANNEL_ID, channelName, channelImportance).apply {
                description = channelDescription
            }

            val notificationManager = applicationContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)

        }

        with(NotificationManagerCompat.from(applicationContext)){
            notify(NOTIFICATION, notification.build())
        }
    }
}