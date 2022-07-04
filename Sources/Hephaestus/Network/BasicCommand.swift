//
//  File.swift
//  
//
//  Created by Eugene Ivanov on 04.07.2022.
//

import Foundation

open class BasicCommand {
    public init() { }
    
    let service: BasicRequestable = BasicRequestable()
    
    open var endpoint: Endpoint {
        fatalError("No Endpoint")
    }
    open var object: Codable {
        fatalError("No Object")
    }
    
    open var httpMethod: HTTPMethod {
        .post
    }
    open var body: Data? {
        nil
    }
    
    open func send<T: Codable>(completion: @escaping (Result<T, Error>) -> Void) {
        service.sendRequest(.init(endpoint: endpoint, httpMethod: httpMethod, body: body), completion: completion)
    }
}
open class CachableCommand: BasicCommand {
    public override init() { }

    open var expirationInterval: TimeInterval {
        CacheExpiration.fiveMinutes
    }
    open override func send<T: Codable>(completion: @escaping (Result<T, Error>) -> Void) {
        let req = CachableRequeste(
            endpoint: endpoint,
            httpMethod: httpMethod,
            expirationInterval: expirationInterval,
            body: body
        )
        service.sendRequest(req, completion: completion)
    }
}
