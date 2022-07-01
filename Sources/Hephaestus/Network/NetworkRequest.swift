
import Foundation

open class NetworkRequest: ServerRequestsLoging {
    let endpoint: Endpoint
    let body: Data?
    let httpMethod: HTTPMethod
    
    var isLogging: Bool = false
    var isLoggingToFile: Bool = false
    
    var fullRequestString: String {
        return endpoint.methodPath + httpMethod.rawValue
    }
    
    public init(
        endpoint: Endpoint,
        httpMethod: HTTPMethod,
        body: Encodable? = nil
    ) {
        self.endpoint = endpoint
        self.body = body?.encode()
        self.httpMethod = httpMethod
    }

    public init(
        endpoint: Endpoint,
        httpMethod: HTTPMethod,
        reqBody: Data? = nil
    ) {
        self.endpoint = endpoint
        self.body = reqBody
        self.httpMethod = httpMethod
    }
    
    func parse() -> URLRequest? {
        guard let url = URL(string: self.endpoint.methodPath) else {
            return nil
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue
        urlRequest.allHTTPHeaderFields = endpoint.headers
        urlRequest.httpBody = body
        return urlRequest
    }
}
