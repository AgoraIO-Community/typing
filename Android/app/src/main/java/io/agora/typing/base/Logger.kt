package io.agora.typing.base

import android.util.Log

enum class LogLevel {
    Info, Warning, Error
}

class Logger {
    companion object {
        const val debug = true
        const val tag = "chat"

        fun log(message: String, level: LogLevel) {
            if (!debug && level != LogLevel.Error) {
                return
            }
            when (level) {
                LogLevel.Info -> Log.d(tag, "$message (${Thread.currentThread().name})")
                LogLevel.Warning -> Log.w(tag, message)
                LogLevel.Error -> Log.e(tag, message)
            }
        }
    }
}