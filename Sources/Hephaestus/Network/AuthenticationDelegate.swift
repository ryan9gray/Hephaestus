//
//  AuthenticationDelegate.swift
//  AuthenticationDelegate
//
//  Created by Evgeny Ivanov on 08.08.2021.
//

import Foundation
import UIKit

protocol AuthicationControllerProtocol {
    func credentialsFromUI() -> Credential?
}
struct Credential {
    let name: String
    let pass: String
}
class AuthenticationDelegate: NSObject, URLSessionTaskDelegate {
    private let controller: AuthicationControllerProtocol
    init(controller: AuthicationControllerProtocol) {
        self.controller = controller
    }
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic {
            guard let cred = controller.credentialsFromUI() else {
                return (.cancelAuthenticationChallenge ,nil)
            }
            return (.useCredential ,URLCredential(user: cred.name, password: cred.pass, persistence: .forSession))
        } else {
            return (.performDefaultHandling, nil)
        }
    }
}
