package io.agora.typing.ui.chat

import androidx.lifecycle.*
import io.agora.typing.base.Message
import io.agora.typing.server.Server
import kotlinx.coroutines.*
import kotlinx.coroutines.channels.ConflatedBroadcastChannel
import kotlinx.coroutines.flow.*

@FlowPreview
@ExperimentalCoroutinesApi
class ChatModel : ViewModel() {

    private var inputMessage = ConflatedBroadcastChannel<String>()
    private var vibrateMessage = ConflatedBroadcastChannel<Boolean>()
    /**
     * Request a snackbar to display a string.
     */
    val snackBar = MutableLiveData<String?>()

    /**
     * Called immediately after the UI shows the snackbar.
     */
    fun onSnackbarShown() {
        snackBar.value = null
    }

    fun sendMessage(message: String) {
        inputMessage.offer(message)
    }

    fun vibrate() {
        vibrateMessage.offer(true)
    }

    fun receivedMessage(name: String) =
        Server.Instance.subscribeFriendMessage(name).asLiveData(Dispatchers.Main)

    fun onlineStatus(name: String) =
        Server.Instance.subscribeUserOnlineState(name).asLiveData(Dispatchers.Main)

    fun onInputMessage(name: String) =
        inputMessage
            .asFlow()
            .distinctUntilChanged()
            .debounce(50)
            .flatMapMerge { message ->
                Server.Instance.sendMessage(Message.text(message), name)
            }
            .flowOn(Dispatchers.Default)
            .asLiveData(Dispatchers.Main)

    fun onVibrateMessage(name: String) =
        vibrateMessage
            .asFlow()
            .debounce(200)
            .flatMapMerge {
                Server.Instance.sendMessage(Message.vibrate(), name)
            }
            .flowOn(Dispatchers.Default)
            .asLiveData(Dispatchers.Main)
}