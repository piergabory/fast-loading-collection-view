import Foundation

public struct Request<Body: Encodable & Sendable>: Sendable {
    enum HTTPMethod: String {
        case GET
        case POST
    }

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let session: URLSession
    private let baseURL = URL(string: apiSecrets.serverURL)!
    private let path: Path
    private let method: HTTPMethod
    private let queryItems: [URLQueryItem]
    private let body: Body?

    init(
        path: Path,
        queryItems: [URLQueryItem] = [],
        method: HTTPMethod = .GET,
        session: URLSession = .shared,
    ) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.body = nil
        self.session = session
    }

    init(
        path: Path,
        body: Body?,
        queryItems: [URLQueryItem] = [],
        session: URLSession = .shared,
    ) {
        self.path = path
        self.method = .POST
        self.queryItems = queryItems
        self.body = body
        self.session = session
    }

    func send<R: Decodable>(expecting _: R.Type = R.self) async throws -> R {
        let data = try await send()
        return try decoder.decode(R.self, from: data)
    }

    func send() async throws -> Data {
        let request = try prepareRequest()
        let (data, response) = try await session.data(for: request)

        guard let response = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200..<300).contains(response.statusCode) else {
            throw HTTPStatus(
                code: response.statusCode,
                body: String(data: data, encoding: .utf8)
            )
        }

        return data
    }

    private func prepareRequest() throws -> URLRequest {
        var request = URLRequest(url: composeURL())
        request.httpMethod = method.rawValue

        if let body {
            request.httpBody = try encoder.encode(body)
            request.setValue(
                "application/json",
                forHTTPHeaderField: "Content-Type",
            )
        }

        request.setValue(
            apiSecrets.apiKey,
            forHTTPHeaderField: "x-api-key",
        )

        return request
    }

    private func composeURL() -> URL {
        path.components
            .reduce(baseURL) { url, component in
                url.appending(component: component)
            }
            .appending(queryItems: queryItems)
    }
}
