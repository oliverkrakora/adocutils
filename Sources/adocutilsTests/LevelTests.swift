//
//  LevelTestRunner.swift
//  
//
//  Created by Oliver Krakora on 04.12.22.
//

import Foundation
import XCTest
import adocutils

open class LevelTests: XCTestCase {

    open var executableBundle: Bundle {
        Bundle.main
    }

    open var resourceBundle: Bundle {
        Bundle.main
    }

    open func testLevelImplementations() async throws {
        let levels = LevelRunner.levels(bundle: executableBundle)

        for level in levels {
            let outputMessage = " \(String(reflecting: level))"
            guard let inputURL = self.input(for: level), let expectedOutput = self.expectedOutput(for: level) else {
                print("⏭" + outputMessage)
                continue
            }
            let solution = try await level.solve(input: inputURL)
            let isEqual = "\(solution)" == expectedOutput
            print("\(isEqual ? "✅" : "❌")" + outputMessage)
            XCTAssertEqual("\(solution)", expectedOutput)
        }
    }

    open func input(for level: Level) -> URL? {
        guard let config = LevelRunner.config(for: level) else { return nil }
        return resourceBundle.url(forResource: "level_\(config.day)_1_input", withExtension: nil)
    }

    open func expectedOutput(for level: Level) -> String? {
        guard let outputURL = expectedOutputURL(for: level) else { return nil }
        return (try? Data(contentsOf: outputURL)).flatMap { String(data: $0, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) }
    }

    open func expectedOutputURL(for level: Level) -> URL? {
        guard let config = LevelRunner.config(for: level) else { return nil }
        return resourceBundle.url(forResource: "level_\(config.day)_\(config.level.rawValue)_output", withExtension: nil)
    }
}
