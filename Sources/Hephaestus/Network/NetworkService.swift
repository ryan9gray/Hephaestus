//
//  File.swift
//  
//
//  Created by Eugene Ivanov on 29.06.2022.
//
import Foundation

open class NetworkService {

    private var session = URLSession(
        configuration: URLSessionConfiguration.default,
        delegate: nil,
        delegateQueue: nil
    )

    private let queue = DispatchQueue(label: "com.organization.network-manager", attributes: .concurrent)

    deinit {
        self.session.finishTasksAndInvalidate()
    }
}
