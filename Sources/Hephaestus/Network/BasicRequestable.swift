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
    
    private let queue = DispatchQueue(label: "com.Hephaestus.network-manager", attributes: .concurrent)
    
    func encodesParametersInURL(for method: HTTPMethod) -> Bool {
        return [.get, .delete].contains(method)
    }
    
    func sendRequest<T: Codable>(_ req: NetworkRequest, completion: @MainActor @escaping (Result<T, Error>) -> Void) {
            queue.async { //[weak self] in
                guard let self = self else {
                    Task.init {
                        await completion(.failure(NetworkError.noResponse("")))
                    }
                    return
                }
                guard let url = URL(string: req.endpoint.methodPath) else {
                    Task.init {
                        await completion(.failure(NetworkError.badURL("")))
                    }
                    return
                }
                if let cachable = req as? CachableRequeste,
                   let object: T = cachable.cachedResponse() {
                    Task.init {
                        await completion(.success(object))
                    }
                    return
                }
                var request: URLRequest

                if
                    self.encodesParametersInURL(for: req.httpMethod),
                    let params = req.body?.dictionary
                {
                    var components = URLComponents(
                        url: url,
                        resolvingAgainstBaseURL: false
                    )
                    
                    params.forEach { key, value in
                        components?.queryItems = [.init(name: key, value: "\(value)")]
                    }
                    let newQueryString = [components?.percentEncodedQuery].compactMap { $0 }.joinedWithAmpersands()
                    components?.percentEncodedQuery = newQueryString.isEmpty ? nil : newQueryString
                    guard let urlWithParams = components?.url else {
                        Task.init {
                            await completion(.failure(NetworkError.badURL("Bad Params")))
                        }
                        return
                    }
                    

                    request = URLRequest(url: urlWithParams)

                } else {
                    request = URLRequest(url: url)
                    request.httpBody = req.body.encode()
                }
                
                request.httpMethod = req.httpMethod.rawValue
                req.endpoint.headers.forEach { name, value in
                    request.setValue(value, forHTTPHeaderField: name)
                }
                
                if req.isLogging {
                    let requestBody = String(data: request.httpBody ?? Data(), encoding: .utf8) ?? ""
                    print(requestBody)
                }
 
                let task = self.session.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {
                        Task.init {
                            await completion(.failure(NetworkError.noResponse("")))
                        }
                        return
                    }
                    if let error = error {
                        NSLog(error.localizedDescription)
                    }
                    if req.isLogging {
                        print(ParseWorker.parse(data) ?? "")
                    }
                    if req.isLoggingToFile, let data = req.body, let parameters = data.dictionary {
                        let loggingData: String =  "Params: \(parameters)"
                        LogService.appendLog(with: "request: \(req.fullRequestString) \(loggingData)")
                    }
                    guard let result = try? JSONDecoder().decode(T.self, from: data) else {
                        Task.init {
                            await completion(.failure(NetworkError.invalidJSON("")))
                        }
                        return
                    }
                    if let cachable = req as? CachableRequeste,
                        let json = String(data: data, encoding: .utf8) {
                        cachable.saveJsonToCache(fullJson: json)
                    }
                    Task.init {
                        await completion(.success(result))
                    }
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

