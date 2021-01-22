package io.agora.typing.base

enum class MessageType {
    Text, Vibrate
}

class Message {

    companion object {
        fun text(raw: String): Message {
            return Message(MessageType.Text, raw)
        }

        fun vibrate(): Message {
            return Message(MessageType.Vibrate, "")
        }
    }

    val type: MessageType
    val data: String

    constructor(raw: String) {
        if (raw.startsWith("vibrate://")) {
            this.type = MessageType.Vibrate
            this.data = ""
        } else {
            this.type = MessageType.Text
            this.data = raw.replace("^text://".toRegex(), "")
        }
    }

    private constructor(type: MessageType, data: String) {
        this.type = type
        this.data = data
    }

    override fun toString(): String {
        return when (type) {
            MessageType.Text -> "text://${this.data}"
            MessageType.Vibrate -> "vibrate://${this.data}"
        }
    }
}