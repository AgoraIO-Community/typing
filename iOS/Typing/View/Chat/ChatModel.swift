//
//  ChatModel.swift
//  OpenChat
//
//  Created by XC on 2021/1/14.
//
import Foundation
import Combine
import AudioToolbox
import SwiftUI

class ChatModel: ObservableObject {
    
    @Published var inputMessage = ""
    @Published var receivedMessage = ""
    @Published var isFriendOnline = false
    @Published var onTouch = false
    @Published var showingPopup = false
    @Published var friendAnimation: Int = 0
    @Published var userAnimation: Int = 0
    
    var message = ""
    func showToast(message: String) {
        self.message = message
        self.showingPopup = true
    }
    
    private var messagePublisher: PeerMessagePublisher?
    private var friendStatusPublisher: PeerOnlineStatusPublisher?
    private var disposables = Set<AnyCancellable>()

    func onAppearWithFriend(name: String) {
        Logger.log(message: "onAppearWithFriend \(name)", level: .info)
        let inputScheduler: DispatchQueue = DispatchQueue(label: "input")
        let outputScheduler: DispatchQueue = DispatchQueue(label: "output")

        messagePublisher = Server.shared().subscribeFriendMessage(user: name)
        messagePublisher?
            .objectWillChange
            .subscribe(on: outputScheduler)
            .receive(on: RunLoop.main)
            .map { data in
                Message(raw: self.messagePublisher?.message?.data?.text ?? "")
            }
            .sink { message in
                switch message.type {
                    case .text:
                        self.receivedMessage = message.data
                    case .vibrate:
                        self.vibrate()
                }
            }
            .store(in: &disposables)
        friendStatusPublisher = Server.shared().subscribeUserOnlineState(user: name)
        friendStatusPublisher?
            .objectWillChange
            .subscribe(on: outputScheduler)
            .receive(on: RunLoop.main)
            .sink { data in
                self.isFriendOnline = self.friendStatusPublisher?.value?.data ?? false
            }
            .store(in: &disposables)
        $inputMessage
            .dropFirst(1)
            .debounce(for: .seconds(0.05), scheduler: inputScheduler)
            .flatMap({ value in
                Server.shared().sendMessage(message: Message.text(raw: value), toUser: name)
            })
            .filter { result in
                result.data != .cachedByServer
            }
            .subscribe(on: inputScheduler)
            .receive(on: RunLoop.main)
            .sink { result in
                if !result.success {
                    self.showToast(message: result.message ?? "unknown error!")
                }
            }
            .store(in: &disposables)
        $onTouch
            .dropFirst(1)
            .debounce(for: .seconds(0.2), scheduler: inputScheduler)
            .flatMap({ _ in
                Server.shared().sendMessage(message: Message.vibrate(), toUser: name)
            })
            .filter { result in
                result.data != .cachedByServer
            }
            .subscribe(on: inputScheduler)
            .receive(on: RunLoop.main)
            .sink { result in
                if !result.success {
                    self.showToast(message: result.message ?? "unknown error!")
                }
            }
            .store(in: &disposables)
    }
    
    func touchAction() {
        onTouch = !onTouch
        withAnimation(.default) {
            self.friendAnimation += 1
        }
    }
    
    func onFinish() {
        inputMessage = ""
    }
    
    func onDisappear() {
        disposables.forEach { cancellable in
            cancellable.cancel()
        }
        disposables.removeAll()
        guard let publisher = messagePublisher else {
            return
        }
        Server.shared().unsubscribeFriendMessage(publisher: publisher)
        guard let statusPublisher = friendStatusPublisher else {
            return
        }
        Server.shared().unsubscribeUserOnlineState(publisher: statusPublisher)
        _ = Server.shared().logout()
    }
    
    func vibrate() {
        withAnimation(.default) {
            self.userAnimation += 1
        }
        AudioServicesPlaySystemSound(1521);
    }
}
