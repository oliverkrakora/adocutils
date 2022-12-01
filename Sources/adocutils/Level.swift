//
//  Level.swift
//  
//
//  Created by Oliver Krakora on 01.12.22.
//

import Foundation

public struct LevelConfig {
    public let day: UInt
    public let level: ADOCClient.Level

    public init(day: UInt, level: ADOCClient.Level) {
        self.day = day
        self.level = level
    }
}

public protocol Level: AnyObject {

    var config: LevelConfig? { get }

    init()

    func solve(input: URL) async throws -> LosslessStringConvertible
}

public extension Level {
    var config: LevelConfig? {
        return nil
    }
}
