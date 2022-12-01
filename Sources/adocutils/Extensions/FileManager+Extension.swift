//
//  File.swift
//  
//
//  Created by Oliver Krakora on 01.12.22.
//

import Foundation

extension FileManager {
    static let applicationSupportDirectory: URL = {
        try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("adventofcode")
    }()
}
