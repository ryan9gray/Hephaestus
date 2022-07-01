//
//  File.swift
//  
//
//  Created by Eugene Ivanov on 29.06.2022.
//

import Foundation

open class BasicRequestable {

    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.httpCookieStorage = HTTPCookieStorage.shared
        configuration.httpCookieAcceptPolicy = .always
        let session = URLSession(configuration: configuration)
        return session
    }()
    
    private let queue = DispatchQueue(label: "com.organization.network-manager", attributes: .concurrent)

    func sendRequest<T: Codable>(_ req: NetworkRequest, decodeTo: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
            queue.async { [weak self] in
                guard let self = self else {
                    completion(.failure(NetworkError.noResponse("")))
                    return
                }
                guard let url = URL(string: req.endpoint.methodPath) else {
                    completion(.failure(NetworkError.badURL("")))
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = req.httpMethod.rawValue
                req.endpoint.headers.forEach { name, value in
                    request.setValue(value, forHTTPHeaderField: name)
                }
                request.httpBody = req.body
                if req.isLogging {
                    let requestBody = String(data: request.httpBody ?? Data(), encoding: .utf8) ?? ""
                    print(requestBody)
                }
 
                let task = self.session.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {
                        completion(.failure(NetworkError.noResponse("")))
                        return
                    }
                    if let error = error {
                        NSLog(error.localizedDescription)
                    }
                    if req.isLogging {
                        print(ParseWorker.parse(data) ?? "")
                    }
                    if req.isLoggingToFile, let data = req.body, let parameters = data.toDictionary() {
                        let loggingData: String =  "Params: \(parameters)"
                        LogService.appendLog(with: "request: \(req.fullRequestString) \(loggingData)")
                    }
                    guard let result = try? JSONDecoder().decode(T.self, from: data) else {
                        completion(.failure(NetworkError.invalidJSON("")))
                        return
                    }
                    if let cachable = req as? CachableRequestable,
                        let json = String(data: data, encoding: .utf8) {
                        cachable.saveJsonToCache(fullJson: json)
                    }
                    completion(.success(result))
                }
                task.resume()
            }
        }

    func download(from: String) {
        guard let url = URL(string: from) else { return }

        let task = URLSession.shared.downloadTask(with: url) { localURL, urlResponse, error in
            if let localURL = localURL {
                if let string = try? String(contentsOf: localURL) {
                    print(string)
                }
            }
        }

        task.resume()
    }
}

