
import Combine
import Foundation

public protocol Requestable {
    @available(iOS 13.0, *)
    func execute<T: Codable>(_ req: NetworkRequest) -> AnyPublisher<T, NetworkError>
    @available(iOS 15.0, *)
    func execute<T: Codable>(_ req: NetworkRequest) async throws -> T
}

public class CombineRequestable: Requestable {
    public var environment: Configuration = .development
    private var activeSessionTasksMap: ThreadSafeDictionary<UUID, URLSessionTask> = .init()
    var authDelegate: AuthenticationDelegate?

    init() {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.httpCookieStorage = HTTPCookieStorage.shared
        sessionConfig.httpCookieAcceptPolicy = .always
    }

    @available(iOS 13.0, *)
    public func execute<T: Codable>(_ req: NetworkRequest) -> AnyPublisher<T, NetworkError> {
        URLSessionConfiguration.default.timeoutIntervalForRequest = TimeInterval(req.endpoint.requestTimeOut)

        guard let request = req.parse() else {
            return AnyPublisher(
                Fail<T, NetworkError>(error: NetworkError.badURL("Invalid Url"))
            )
        }
        // We use the dataTaskPublisher from the URLSession which gives us a publisher to play around with.
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { output in
                guard output.response is HTTPURLResponse else {
                    throw NetworkError.serverError(code: 0, error: "Server error")
                }
                return output.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                NetworkError.invalidJSON(String(describing: error))
            }
            .eraseToAnyPublisher()
    }

    @available(iOS 15.0, *)
    public func execute<T: Codable>(_ req: NetworkRequest) async throws -> T {
        URLSessionConfiguration.default.timeoutIntervalForRequest = TimeInterval(req.endpoint.requestTimeOut)
        guard let request = req.parse() else {
            throw NetworkError.badURL("Invalid Url")
        }

        let (data, response) = try await URLSession.shared.data(for: request, delegate: authDelegate)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noResponse("unvalid response")
        }
        guard 200...399 ~= httpResponse.statusCode  else {
            throw NetworkError.apiError(code: httpResponse.statusCode, error: "Error")
        }
        guard let model = try? JSONDecoder().decode(T.self, from: data) else {
            throw NetworkError.invalidJSON("JSONDecoder")
        }
        return model
    }
}
