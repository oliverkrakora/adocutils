//
//  File.swift
//  
//
//  Created by Oliver Krakora on 04.12.22.
//

import Foundation

// not async but it does it for now
public extension URL {
    var allLines: AsyncThrowingStream<String, Error> {
        AsyncThrowingStream(String.self) { continuation in
            Task {
                do {
                    let data = try Data(contentsOf: self)
                    let string = String(data: data, encoding: .utf8)
                    var lines = string?.components(separatedBy: "\n") ?? []

                    for line in lines {
                        continuation.yield(with: .success(line))
                    }
                    continuation.finish()

                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
