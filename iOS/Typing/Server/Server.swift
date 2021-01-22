//
//  File.swift
//  OpenChat
//
//  Created by XC on 2021/1/15.
//

import Combine
import Foundation
import AgoraRtmKit

enum UserStatus {
    case online, offline
}

class User {
    let name: String
    var status: UserStatus = .offline
    
    init(name: String) {
        self.name = name
    }
}

class Server: NSObject {
    fileprivate static let instance = Server()
    
    static func shared() -> Service {
        return instance
    }

    fileprivate var agoraRtmKit = AgoraRtmKit(appId: KeyCenter.AppId, delegate: nil)
    
    fileprivate var account: User?
    var connectionState: AgoraRtmConnectionState = .disconnected
    
    fileprivate var peerOnlineStatusPublishers: [PeerOnlineStatusPublisher] = []
    fileprivate var peerMessagePublishers: [PeerMessagePublisher] = []
}

extension Server: Service {
    func login(user: String) -> AnyPublisher<Result<Void>, Never> {
        agoraRtmKit?.agoraRtmDelegate = self
        var needLogout = false
        if let account = self.account {
            if account.status == .online {
                if account.name == user {
                    return Just(Result<Void>(success: true)).eraseToAnyPublisher()
                } else {
                    needLogout = true
                }
            }
        }
        return Just(needLogout)
            .flatMap { need -> AnyPublisher<Result<Void>, Never> in
                if need {
                    return self.logout()
                } else {
                    return Just(Result<Void>(success: true)).eraseToAnyPublisher()
                }
            }
            .flatMap { result in
                return Future() { promise in
                    guard let kit = self.agoraRtmKit else {
                        Logger.log(message: "AgoraRtmKit nil", level: .error)
                        promise(.success(Result<Void>(success: false, message: "AgoraRtmKit nil")))
                        return
                    }
                    
                    Logger.log(message: "login with id:\(user)", level: .info)
                    kit.login(byToken: KeyCenter.Token, user: user) { code in
                        guard code == AgoraRtmLoginErrorCode.ok else {
                            Logger.log(message: "login fail:\(code.rawValue)", level: .error)
                            promise(.success(Result<Void>(success: false, message: "login fail:\(code.rawValue)")))
                            return
                        }
                        self.account = User(name: user)
                        self.account?.status = .online
                        promise(.success(Result<Void>(success: true)))
                    }
                }
            }.eraseToAnyPublisher()
    }
    
    func logout() -> AnyPublisher<Result<Void>, Never> {
        return Future() { promise in
            guard let kit = self.agoraRtmKit else {
                Logger.log(message: "AgoraRtmKit nil", level: .error)
                promise(.success(Result<Void>(success: false, message: "AgoraRtmKit nil")))
                return
            }
            if let account = self.account {
                if account.status == .online {
                    kit.logout { code in
                        guard code == .ok else {
                            Logger.log(message: "logout fail:\(code.rawValue)", level: .error)
                            promise(.success(Result<Void>(success: false, message: "logout fail:\(code.rawValue)")))
                            return
                        }
                        Logger.log(message: "\(account) logout success", level: .info)
                    }
                }
            }
            self.account = nil
            promise(.success(Result<Void>(success: true)))
        }.eraseToAnyPublisher()
    }
    
    func subscribeUserOnlineState(user: String) -> PeerOnlineStatusPublisher {
        Logger.log(message: "subscribeUserOnlineState user:\(user)", level: .info)
        let find = peerOnlineStatusPublishers.first { publisher in
            publisher.peerId == user
        }
        let publisher = find ?? PeerOnlineStatusPublisher(peerId: user)
        if find == nil {
            peerOnlineStatusPublishers.append(publisher)
        }
        guard let kit = self.agoraRtmKit else {
            publisher.onError(error: .AgoraRtmPeerSubscriptionStatusErrorNotInitialized)
            return publisher
        }
        kit.subscribePeersOnlineStatus([user]) { error in
            publisher.onError(error: error)
        }
        return publisher
    }
    
    func unsubscribeUserOnlineState(publisher: PeerOnlineStatusPublisher) {
        Logger.log(message: "unsubscribeUserOnlineState user:\(publisher.peerId)", level: .info)
        let find = peerOnlineStatusPublishers.firstIndex { publisher in
            publisher.peerId == publisher.peerId
        }
        guard let index = find else {
            return
        }
        peerOnlineStatusPublishers.remove(at: index)
    }
    
    func sendMessage(message: Message, toUser: String) -> AnyPublisher<Result<AgoraRtmSendPeerMessageErrorCode>, Never> {
        Logger.log(message: "sendMessage message:\(message.toString())", level: .info)
        return Future() { promise in
            guard let kit = self.agoraRtmKit else {
                Logger.log(message: "AgoraRtmKit nil", level: .error)
                promise(.success(Result<AgoraRtmSendPeerMessageErrorCode>(success: false, message: "AgoraRtmKit nil")))
                return
            }
            let rtmMessage = AgoraRtmMessage(text: message.toString())
            let find = self.peerOnlineStatusPublishers.first { publisher in
                publisher.peerId == toUser
            }
            let isOnline = find?.value?.data ?? false
            let option = AgoraRtmSendMessageOptions()
            option.enableOfflineMessaging = !isOnline
            
            kit.send(rtmMessage, toPeer: toUser, sendMessageOptions: option) { code in
                if code == .ok {
                    promise(.success(Result<AgoraRtmSendPeerMessageErrorCode>(success: true)))
                } else {
                    promise(.success(Result<AgoraRtmSendPeerMessageErrorCode>(success: false, data: code, message: code.description())))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func subscribeFriendMessage(user: String) -> PeerMessagePublisher {
        Logger.log(message: "subscribeFriendMessage user:\(user)", level: .info)
        let find = peerMessagePublishers.first { publisher in
            publisher.peerId == user
        }
        let publisher = find ?? PeerMessagePublisher(peerId: user)
        if find == nil {
            peerMessagePublishers.append(publisher)
        }
        return publisher
    }
    
    func unsubscribeFriendMessage(publisher: PeerMessagePublisher) {
        Logger.log(message: "unsubscribeFriendMessage user:\(publisher.peerId)", level: .info)
        let find = peerMessagePublishers.firstIndex { publisher in
            publisher.peerId == publisher.peerId
        }
        guard let index = find else {
            return
        }
        peerMessagePublishers.remove(at: index)
    }
}

extension Server: AgoraRtmDelegate {
    func rtmKit(_ kit: AgoraRtmKit, peersOnlineStatusChanged onlineStatus: [AgoraRtmPeerOnlineStatus]) {
        Logger.log(message: "peersOnlineStatusChanged", level: .info)
        self.peerOnlineStatusPublishers.forEach { handler in
            let status = onlineStatus.first { peerOnlineStatus in
                return peerOnlineStatus.peerId == handler.peerId
            }
            if status != nil {
                handler.onChanged(status: status!)
            }
        }
    }
    
    func rtmKit(_ kit: AgoraRtmKit, connectionStateChanged state: AgoraRtmConnectionState, reason: AgoraRtmConnectionChangeReason) {
        Logger.log(message: "connectionStateChanged \(state.description())", level: .info)
        self.connectionState = state
    }
    
    func rtmKit(_ kit: AgoraRtmKit, messageReceived message: AgoraRtmMessage, fromPeer peerId: String) {
        Logger.log(message: "messageReceived \(message.text)", level: .info)
        let all = self.peerMessagePublishers.filter { publisher in
            return publisher.peerId == peerId
        }
        all.forEach { publisher in
            publisher.messageReceived(message: message)
        }
    }
}
