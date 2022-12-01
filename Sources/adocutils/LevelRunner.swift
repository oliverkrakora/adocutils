//
//  LevelRunner.swift
//  
//
//  Created by Oliver Krakora on 04.12.22.
//

import Foundation

public class LevelRunner {

    public enum Error: Swift.Error {
        case unknownLevel
    }

    private let client: ADOCClient

    public init(client: ADOCClient) {
        self.client = client
    }

    public func solveAll(bundle: Bundle, continueWhenLevelFails: Bool = false) async throws {
        let classes = Self.levelClasses(bundle: bundle)
        try await solve(levels: classes, continueWhenLevelFails: continueWhenLevelFails)
    }

    public func solve(levels: [AnyClass], continueWhenLevelFails: Bool = false) async throws {
        for level in levels {
            guard let levelClass = level as? Level.Type else {
                print("Class \(level) does not conform to Level.")
                continue
            }
            do {
                try await solve(level: levelClass.init())
            } catch {
                if continueWhenLevelFails {
                    continue
                } else {
                    throw error
                }
            }
        }
    }

    public func solve(level: Level, force: Bool = false) async throws {
        guard let config = Self.config(for: level) else {
            throw Error.unknownLevel
        }

        let isSolved = try await client.isSolved(day: config.day, level: config.level)
        guard !isSolved || force else { return }

        let inputURL = try await client.input(forDay: config.day)
        let solution = try await level.solve(input: inputURL)

        try await client.submitAnswer(solution, forDay: config.day, level: config.level)
    }
}

// MARK: Helpers
public extension LevelRunner {
    static func levelClasses(bundle: Bundle) -> [AnyClass] {
        let levelNames = (1...24).flatMap {
            ["Level_\($0)_1", "Level_\($0)_2"]
        }

        let bundlePrefix = bundle.bundleURL.lastPathComponent.split(separator: "_").first ?? ""

        var classes = [AnyClass]()
        for levelName in levelNames {
            let className = bundlePrefix + "." + levelName
            guard let levelClass = NSClassFromString(className) else { continue }
            guard levelClass is Level.Type else { continue }
            classes.append(levelClass)
        }

        return classes
    }

    static func levels(bundle: Bundle) -> [Level] {
        levelClasses(bundle: bundle).map { ($0 as! Level.Type).init() }
    }

    static func config(for level: Level) -> LevelConfig? {
        if let config = level.config {
            return config
        } else {
            let splittedName = String(reflecting: type(of: level)).split(separator: "_")
            guard splittedName.count == 3 else { return nil }
            guard let day = UInt(splittedName[1]), let level = UInt(splittedName[2]).flatMap({ ADOCClient.Level(rawValue: $0) }) else { return nil }
            return LevelConfig(day: day, level: level)
        }
    }
}
