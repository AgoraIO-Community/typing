//
//  TextMessage.swift
//  OpenChat
//
//  Created by XC on 2021/1/21.
//

import Foundation

enum MessageType {
    case text, vibrate
}

struct Message {
    
    let type: MessageType
    let data: String
    
    init(raw: String) {
        if raw.starts(with: "vibrate://") {
            type = .vibrate
            data = ""
        } else {
            type = .text
            if let regex = try? NSRegularExpression(pattern: "^text://", options: .anchorsMatchLines) {
                data = regex.stringByReplacingMatches(in: raw, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange(location: 0, length: raw.count), withTemplate: "")
            } else {
                data = raw
            }
        }
    }
    
    fileprivate init(type: MessageType, data: String) {
        self.type = type
        self.data = data
    }
    
    func toString() -> String {
        switch type {
        case .text:
            return "text://\(data)"
        case .vibrate:
            return "vibrate://\(data)"
        }
    }
    
    static func text(raw: String) -> Message {
        return Message(type: .text, data: raw)
    }
    
    static func vibrate() -> Message {
        return Message(type: .vibrate, data: "")
    }
}
