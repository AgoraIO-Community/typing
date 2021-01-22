//
//  Extension.swift
//  OpenChat
//
//  Created by XC on 2021/1/16.
//

import Foundation
import SwiftUI
import AgoraRtmKit

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension AgoraRtmPeerSubscriptionStatusErrorCode {
    func description() -> String {
        switch self {
        case .AgoraRtmPeerSubscriptionStatusErrorOk:
            return "Ok"
        case .AgoraRtmPeerSubscriptionStatusErrorFailure:
            return "Failure"
        case .AgoraRtmPeerSubscriptionStatusErrorInvalidArgument:
            return "Invalid Argument"
        case .AgoraRtmPeerSubscriptionStatusErrorRejected:
            return "Rejected"
        case .AgoraRtmPeerSubscriptionStatusErrorTimeout:
            return "Timeout"
        case .AgoraRtmPeerSubscriptionStatusErrorTooOften:
            return "TooOften"
        case .PEER_SUBSCRIPTION_STATUS_ERR_OVERFLOW:
            return "Overflow"
        case .AgoraRtmPeerSubscriptionStatusErrorNotInitialized:
            return "NotInitialized"
        case .AgoraRtmPeerSubscriptionStatusErrorNotLoggedIn:
            return "NotLoggedIn"
        default:
            return "Unknown Error"
        }
    }
}

extension AgoraRtmSendPeerMessageErrorCode {
    func description() -> String {
        switch self {
        case .ok:
            return "Ok"
        case .failure:
            return "Failure"
        case .timeout:
            return "Timeout"
        case .peerUnreachable:
            return "Unreachable"
        case .cachedByServer:
            return "CachedByServer"
        case .tooOften:
            return "TooOften"
        case .invalidUserId:
            return "InvalidUserId"
        case .invalidMessage:
            return "InvalidMessage"
        case .notInitialized:
            return "NotInitialized"
        case .notLoggedIn:
            return "NotLoggedIn"
        default:
            return "Unknown Error"
        }
    }
}
extension AgoraRtmConnectionState {
    func description() -> String {
        switch self {
        case .disconnected:
            return "Disconnected"
        case .connecting:
            return "Connecting"
        case .connected:
            return "Connected"
        case .reconnecting:
            return "Reconnecting"
        case .aborted:
            return "Aborted"
        default:
            return "Unknown Error"
        }
    }
}
