//
//  Logger.swift
//  Toolkit
//
//  Created by Andras Olah on 2025. 12. 23..
//

import OSLog

public struct Logger: LoggerInterface {
    private let logger: os.Logger

    public init(identifier: String, category: String = "App") {
        self.logger = os.Logger(subsystem: identifier, category: category)
    }

    public func trace(_ message: @autoclosure () -> String,
                      file: String, function: String, line: Int) {
        #if DEBUG
        let traceMsg = "🕵🏼 [\(file):\(line)] \(function) - \(message())"
        logger.trace("\(traceMsg)")
        #endif
    }

    public func debug(_ message: @autoclosure () -> String,
                      file: String, function: String, line: Int) {
        #if DEBUG
        let debugMsg = "🚧 [\(file):\(line)] \(function) - \(message())"
        logger.debug("\(debugMsg)")
        #endif
    }

    public func info(_ message: @autoclosure () -> String,
                     file: String, function: String, line: Int) {
        #if DEBUG
        let infoMsg = "ℹ️ [\(file):\(line)] \(function) - \(message())"
        logger.info("\(infoMsg)")
        #endif
    }

    public func warn(_ message: @autoclosure () -> String,
                     file: String, function: String, line: Int) {
        let warningMsg = "⚠️ [\(file):\(line)] \(function) - \(message())"
        logger.warning("\(warningMsg)")
    }

    public func error(_ message: @autoclosure () -> String,
                      file: String, function: String, line: Int) {
        let errorMsg = "🛑 [\(file):\(line)] \(function) - \(message())"
        logger.error("\(errorMsg)")
    }

    public func fatal(_ message: @autoclosure () -> String,
                      file: String, function: String, line: Int) -> Never {
        let fatalMsg = "☠️ [\(file):\(line)] \(function) - \(message())"
        logger.fault("\(fatalMsg)")
        fatalError(fatalMsg)
    }
}
