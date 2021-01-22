package io.agora.typing.base

import io.agora.rtm.RtmMessage
import kotlinx.coroutines.flow.Flow

data class Result<T>(val success: Boolean, val data: T? = null, val message: String? = null)
data class UserMessage(val name: String? = null, val message: RtmMessage? = null)

interface Service {
    fun login(user: String): Flow<Result<Void>>
    fun logout(): Flow<Result<Void>>
    fun sendMessage(message: Message, toUser: String): Flow<Result<Int>>
    fun subscribeUserOnlineState(user: String): Flow<Result<Boolean>>
    fun subscribeFriendMessage(user: String): Flow<Result<UserMessage>>
}