package io.agora.typing.server

import io.agora.typing.App
import io.agora.typing.base.*
import io.agora.rtm.*
import kotlinx.coroutines.*
import kotlinx.coroutines.channels.ConflatedBroadcastChannel
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.*
import java.util.concurrent.CancellationException

enum class UserStatus {
    Online, Offline
}

data class User(val name: String, var status: UserStatus = UserStatus.Offline)

class WithErrorInfoError(override val message: String, val info: ErrorInfo? = null) : CancellationException(message)

@FlowPreview
@ExperimentalCoroutinesApi
class Server : Service, RtmClientListener {

    companion object {
        val Instance: Server by lazy(mode = LazyThreadSafetyMode.SYNCHRONIZED) {
            Server()
        }
    }

    private var account: User? = null
    private val agoraRtmKit = RtmClient.createInstance(App.instance, BuildConfig.appId, this)

    override fun login(user: String): Flow<Result<Void>> {
        Logger.log("login with id:$user", LogLevel.Info)
        var needLogout = false
        if (account?.status == UserStatus.Online) {
            if (account?.name == user) {
                return flowOf(Result(true))
            } else {
                needLogout = true
            }
        }
        return flowOf(needLogout).flatMapConcat {
            if (!it) {
                flowOf(Result(true))
            } else {
                logout()
            }
        }.flatMapConcat {
            if (it.success) {
                callbackFlow {
                    val callback = object : ResultCallback<Void> {
                        override fun onSuccess(p0: Void?) {
                            account = User(user, UserStatus.Online)
                            offer(Result(true))
                            channel.close()
                        }

                        override fun onFailure(error: ErrorInfo?) {
                            val errorCode = error?.errorCode
                            val message = error?.errorDescription ?: "unknown error"
                            Logger.log("login fail ($errorCode $message)", LogLevel.Error)
                            cancel(WithErrorInfoError(message, error))
                        }
                    }
                    agoraRtmKit.login(BuildConfig.token, user, callback)
                    awaitClose()
                }
            } else {
                flowOf(it)
            }
        }
    }

    override fun logout(): Flow<Result<Void>> {
        Logger.log("logout", LogLevel.Info)
        return if (account?.status != UserStatus.Online) {
            flowOf(Result(true))
        } else {
            callbackFlow {
                val callback = object : ResultCallback<Void> {
                    override fun onSuccess(p0: Void?) {
                        account = null
                        offer(Result(true))
                        channel.close()
                    }

                    override fun onFailure(error: ErrorInfo?) {
                        val errorCode = error?.errorCode
                        val message = error?.errorDescription ?: "unknown error"
                        Logger.log("logout fail ($errorCode $message)", LogLevel.Error)
                        cancel(WithErrorInfoError(message, error))
                        channel.close()
                    }
                }
                agoraRtmKit.logout(callback)
                awaitClose()
            }
        }
    }

    override fun subscribeUserOnlineState(user: String): Flow<Result<Boolean>> {
        val callback = object : ResultCallback<Void> {
            override fun onSuccess(p0: Void?) {
                GlobalScope.launch(Dispatchers.Default) {
                    peerStatusChangeChannel.send(Result(true, User(user)))
                }
            }

            override fun onFailure(error: ErrorInfo?) {
                GlobalScope.launch(Dispatchers.Default) {
                    peerStatusChangeChannel.send(
                        Result(
                            false,
                            User(user),
                            message = error?.errorDescription ?: "unknown error"
                        )
                    )
                }
            }
        }
        agoraRtmKit.subscribePeersOnlineStatus(setOf(user), callback)
        return peerStatusChangeChannel.asFlow().filter { result ->
            result.data?.name == user
        }.map { result ->
            Logger.log("user: ${result.data?.name} status: ${result.data?.status}", LogLevel.Info)
            Result(
                result.success,
                data = result.data?.status  == UserStatus.Online,
                message = result.message
            )
        }.flowOn(Dispatchers.IO)
    }

    override fun sendMessage(
        message: Message,
        toUser: String
    ): Flow<Result<Int>> {
        return callbackFlow {
            val callback = object : ResultCallback<Void> {
                override fun onSuccess(p0: Void?) {
                    offer(Result(true))
                    channel.close()
                }

                override fun onFailure(error: ErrorInfo?) {
                    val errorCode = error?.errorCode
                    val errorDescription = error?.errorDescription ?: "unknown error"
                    Logger.log("sendMessage ($errorCode $errorDescription)", LogLevel.Error)
                    if (errorCode == RtmStatusCode.PeerMessageError.PEER_MESSAGE_ERR_CACHED_BY_SERVER) {
                        offer(Result(true, errorCode))
                    } else {
                        //cancel(WithErrorInfoError(message, error))
                        offer(Result(false, errorCode, errorDescription))
                    }
                    channel.close()
                }
            }

            val status = peersStatus[toUser] ?: PeerOnlineState.UNREACHABLE
            val option = SendMessageOptions()
            option.enableOfflineMessaging = status != PeerOnlineState.ONLINE
            agoraRtmKit.sendMessageToPeer(
                toUser,
                agoraRtmKit.createMessage(message.toString()),
                option,
                callback
            )
            Logger.log("sendMessage to: $toUser", LogLevel.Info)
            awaitClose()
        }
    }

    override fun subscribeFriendMessage(user: String): Flow<Result<UserMessage>> {
        return peerMessageChannel.asFlow().filter { result ->
            result.success && result.data?.name == user && result.data.message != null
        }.flowOn(Dispatchers.IO)
    }

    override fun onTokenExpired() {
        Logger.log("onTokenExpired", LogLevel.Info)
    }

    private val peersStatus = HashMap<String, Int>()
    private val peerStatusChangeChannel = ConflatedBroadcastChannel<Result<User>>()

    override fun onPeersOnlineStatusChanged(peersStatus: MutableMap<String, Int>?) {
        Logger.log("onPeersOnlineStatusChanged", LogLevel.Info)
        peersStatus?.forEach { item ->
            val peerId = item.key
            val status =
                if (item.value == PeerOnlineState.ONLINE) UserStatus.Online else UserStatus.Offline
            peersStatus[peerId] = item.value
            peerStatusChangeChannel.offer(Result(true, data = User(peerId, status)))
        }
    }

    override fun onConnectionStateChanged(state: Int, reason: Int) {
        Logger.log("onConnectionStateChanged", LogLevel.Info)
    }

    private val peerMessageChannel = ConflatedBroadcastChannel<Result<UserMessage>>()

    override fun onMessageReceived(message: RtmMessage?, peerId: String?) {
        Logger.log("onMessageReceived from:$peerId", LogLevel.Info)
        peerMessageChannel.offer(Result(true, UserMessage(peerId, message)))
    }
}