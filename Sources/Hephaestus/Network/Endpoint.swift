//
//  ServiceEndpoints.swift
//  ServiceEndpoints
//
//  Created by Evgeny Ivanov on 25.07.2021.
//

import Foundation
import UserNotifications

public typealias Headers = [String: String]

public protocol Endpoint {
    var methodPath: String { get }
    var requestTimeOut: Int { get }
    var headers: Headers { get }
}

public extension Endpoint where Self: Hashable {
    var requestTimeOut: Int {
        return 20
    }
    var headers: Headers {
        return [:]
    }
}

public protocol Environment {
    var baseUrl: String { get }
}

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public enum Configuration: String, Environment, CaseIterable {
    case development
    case staging
    case production

    public var baseUrl: String {
        switch self {
            case .development:
                return "https://dev/"
            case .staging:
                return "https://stg/"
            case .production:
                return "https://combine.com/"
        }
    }
    static func activeConfiguration() -> Self {
        #if DEBUG
            return .development
        #else
            return .production
        #endif
    }
}
