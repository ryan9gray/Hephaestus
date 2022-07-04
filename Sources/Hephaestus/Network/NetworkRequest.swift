
import Foundation

open class NetworkRequest: ServerRequestsLoging {
    var endpoint: Endpoint
    var body: Data?
    var httpMethod: HTTPMethod
    
    var isLogging: Bool = true
    var isLoggingToFile: Bool = false
    
    var fullRequestString: String {
        return endpoint.methodPath + httpMethod.rawValue
    }
    
    public init(
        endpoint: Endpoint,
        httpMethod: HTTPMethod,
        body: Data?
    ) {
        self.endpoint = endpoint
        self.body = body
        self.httpMethod = httpMethod
    }
    
    func parse() -> URLRequest? {
        guard let url = URL(string: self.endpoint.methodPath) else {
            return nil
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue
        urlRequest.allHTTPHeaderFields = endpoint.headers
        urlRequest.httpBody = body.encode()
        return urlRequest
    }
}
