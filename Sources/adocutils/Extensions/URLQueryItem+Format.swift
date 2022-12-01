//
//  File.swift
//  
//
//  Created by Oliver Krakora on 01.12.22.
//

import Foundation

extension Collection where Element == URLQueryItem {
    var formEncoded: String {
        reduce(into: "") { (string, item) in
            if !string.isEmpty {
                string += "&"
            }
            string += "\(item.name)=\(item.value ?? "")"
        }
    }
}
