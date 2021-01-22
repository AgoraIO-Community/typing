package io.agora.typing

import androidx.multidex.MultiDexApplication

class App : MultiDexApplication() {
    companion object {
        lateinit var instance: App
    }

    override fun onCreate() {
        super.onCreate()
        instance = this
    }
}