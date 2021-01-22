//
//  Logger.swift
//  OpenChat
//
//  Created by XC on 2021/1/16.
//

import Foundation

enum LogLevel {
    case info, warning, error
    
    var description: String {
        switch self {
        case .info:    return "Info"
        case .warning: return "Warning"
        case .error:   return "Error"
        }
    }
}

class Logger {
    
    fileprivate static let debug = true
    
    static func log(message: String, level: LogLevel) {
        if !debug && level != .error {
            return
        }
        print("\(level.description): \(message)")
    }
}
