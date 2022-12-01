//
//  ADOCClient.swift
//
//
//  Created by Oliver Krakora on 01.12.22.
//

import Foundation

/// Allows downloading inputs and submitting answers to and from adventofcode.com
public class ADOCClient {

    public enum Error: Swift.Error {
        case malformedURL
        case underlying(Swift.Error)
        case http(Int)
    }

    public enum Level: UInt {
        case one = 1
        case two = 2
    }

    public struct Config {
        public let sessionToken: String
        public let year: UInt

        public init(sessionToken: String, year: UInt) {
            self.sessionToken = sessionToken
            self.year = year
        }
    }

    private static let baseURLString = "adventofcode.com"

    private let session: URLSession

    private let config: Config

    public init(config: Config) {
        self.config = config
        self.session = URLSession(configuration: .default)
        let cookieURL = URL(string: "https://\(Self.baseURLString)")!
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: ["Set-Cookie": "session=\(config.sessionToken)"],
                                               for: cookieURL)
        session.configuration.httpCookieStorage?.setCookies(cookies, for: cookieURL, mainDocumentURL: nil)
    }

    /// Loads the input for the specified day and calls the completion closure with a result
    ///
    /// - Parameter forDay: The day for which the input should be loaded
    ///
    /// On success the value of the result is a URL of the loaded input file
    public func input(forDay day: UInt) async throws -> URL {
        let inputURL = self.inputURL(forDay: day)

        guard !FileManager.default.fileExists(atPath: inputURL.path) else { return inputURL }

        let components = createURLComponents(withPath: "/\(config.year)/day/\(day)/input")

        let request = createRequest(withURL: components.url!)

        let (downloadURL, response) = try await session.download(for: request)
        let httpResponse = response as! HTTPURLResponse

        guard httpResponse.statusCode == 200 else {
            throw Error.http(httpResponse.statusCode)
        }

        try moveFile(from: downloadURL, to: inputURL)

        return inputURL
    }

    public func isSolved(day: UInt, level: Level) async throws -> Bool {
        return false
    }

    public func markAsSolved(day: UInt, level: Level) async throws {
    }

    public func submitAnswer(_ answer: LosslessStringConvertible, forDay day: UInt, level: Level) async throws {
        let components = createURLComponents(withPath: "/\(config.year)/day/\(day)/answer")
        var request = createRequest(withURL: components.url!, method: "POST")
        request.httpBody = {
            [
                URLQueryItem(name: "level", value: "\(level.rawValue)"),
                URLQueryItem(name: "answer", value: "\(answer)")
            ].formEncoded
            .data(using: .utf8)
        }()

        _ = try await session.data(for: request)
    }
}

// MARK: Helpers

private extension ADOCClient {

    func createURLComponents(withPath path: String = "") -> URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Self.baseURLString
        components.path = path
        return components
    }

    func createRequest(withURL url: URL, method: String = "GET") -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        return request
    }

    func moveFile(from: URL, to: URL) throws {
        try FileManager.default.createDirectory(at: to.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        try FileManager.default.moveItem(at: from, to: to)
    }

    func inputURL(forDay day: UInt) -> URL {
        FileManager.applicationSupportDirectory
            .appendingPathComponent("\(config.year)/inputs/day/\(day)")
            .appendingPathExtension("txt")
    }
}
