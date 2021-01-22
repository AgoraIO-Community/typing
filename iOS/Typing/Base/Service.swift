//
//  Service.swift
//  OpenChat
//
//  Created by XC on 2021/1/16.
//

import Foundation
import Combine
import AgoraRtmKit

struct Result<T> {
    var success: Bool
    var data: T?
    var message: String?
}

class PeerOnlineStatusPublisher: ObservableObject {
    @Published var value: Result<Bool>?
    let peerId: String

    init(peerId: String) {
        self.peerId = peerId
    }
    
    func onChanged(status: AgoraRtmPeerOnlineStatus) {
        Logger.log(message: "onChanged peerId:\(status.peerId) status:\(status.isOnline)", level: .info)
        self.value = Result<Bool>(success: true, data: status.isOnline)
    }
    
    func onError(error: AgoraRtmPeerSubscriptionStatusErrorCode) {
        if error != .AgoraRtmPeerSubscriptionStatusErrorOk {
            Logger.log(message: "PeerOnlineStatusPublisher onError:\(error.description())", level: .error)
            self.value = Result<Bool>(success: false, message: error.description())
        }
    }
}

class PeerMessagePublisher: ObservableObject {
    @Published var message: Result<AgoraRtmMessage>?
    let peerId: String

    init(peerId: String) {
        self.peerId = peerId
    }
    
    func messageReceived(message: AgoraRtmMessage) {
        if message.type == .text {
            Logger.log(message: "messageReceived \(message.text)", level: .info)
            self.message = Result<AgoraRtmMessage>(success: true, data: message)
        }
    }
}

protocol Service {
    func login(user: String) -> AnyPublisher<Result<Void>, Never>
    func logout() -> AnyPublisher<Result<Void>, Never>
    func subscribeUserOnlineState(user: String) -> PeerOnlineStatusPublisher
    func unsubscribeUserOnlineState(publisher: PeerOnlineStatusPublisher) -> Void
    func sendMessage(message: Message, toUser: String) -> AnyPublisher<Result<AgoraRtmSendPeerMessageErrorCode>, Never>
    func subscribeFriendMessage(user: String) -> PeerMessagePublisher
    func unsubscribeFriendMessage(publisher: PeerMessagePublisher) -> Void
}
