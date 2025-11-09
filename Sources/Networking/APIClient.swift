import Foundation

protocol TokenStore {
    func loadToken() -> String?
    func saveToken(_ token: String?)
}

struct UserDefaultsTokenStore: TokenStore {
    private let defaults: UserDefaults
    private let key: String

    init(defaults: UserDefaults = .standard, key: String = "codex01.jwt.token") {
        self.defaults = defaults
        self.key = key
    }

    func loadToken() -> String? {
        defaults.string(forKey: key)
    }

    func saveToken(_ token: String?) {
        if let token {
            defaults.set(token, forKey: key)
        } else {
            defaults.removeObject(forKey: key)
        }
    }
}

actor APIClient {
    struct Configuration {
        let baseURL: URL
        static let `default` = Configuration(baseURL: URL(string: "http://localhost:8080/api")!)
    }

    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }

    enum APIError: Error, LocalizedError {
        case invalidURL
        case missingToken
        case transport(Error)
        case invalidResponse
        case httpStatus(Int, Data)
        case decoding(Error)
        case encoding(Error)
        case domain(String)

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Failed to build request URL."
            case .missingToken:
                return "No authentication token available."
            case .transport(let error):
                return error.localizedDescription
            case .invalidResponse:
                return "Server response was invalid."
            case .httpStatus(let code, _):
                return "Server responded with status code \(code)."
            case .decoding(let error), .encoding(let error):
                return error.localizedDescription
            case .domain(let message):
                return message
            }
        }
    }

    struct AuthenticatedUser: Hashable {
        let userID: UUID
        let email: String
        let displayName: String
        let location: String
        let bio: String
        let rating: Double
        let dealsCount: Int
    }

    struct AuthSession {
        let token: String
        let user: AuthenticatedUser
    }

    private let configuration: Configuration
    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let tokenStore: TokenStore
    private var cachedToken: String?

    init(
        configuration: Configuration = .default,
        session: URLSession = .shared,
        tokenStore: TokenStore = UserDefaultsTokenStore()
    ) {
        self.configuration = configuration
        self.session = session
        self.tokenStore = tokenStore
        self.cachedToken = tokenStore.loadToken()

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    func login(email: String, password: String) async throws -> AuthSession {
        let request = LoginRequest(email: email, password: password)
        let response: AuthResponse = try await send(
            path: "/auth/login",
            method: .post,
            body: request,
            requiresAuth: false
        )
        let session = try response.toDomain()
        tokenStore.saveToken(session.token)
        cachedToken = session.token
        return session
    }

    func register(email: String, password: String, displayName: String) async throws -> AuthSession {
        let request = RegisterRequest(email: email, password: password, displayName: displayName)
        let response: AuthResponse = try await send(
            path: "/auth/register",
            method: .post,
            body: request,
            requiresAuth: false
        )
        let session = try response.toDomain()
        tokenStore.saveToken(session.token)
        cachedToken = session.token
        return session
    }

    func fetchCurrentUser() async throws -> AuthenticatedUser? {
        guard let token = cachedToken ?? tokenStore.loadToken() else { return nil }
        cachedToken = token
        let response: UserResponse = try await send(
            path: "/auth/me",
            method: .get,
            requiresAuth: true
        )
        return try response.toDomain()
    }

    func fetchListings() async throws -> [SnowboardListing] {
        let response: [ListingResponse] = try await send(
            path: "/listings",
            method: .get,
            requiresAuth: true
        )
        return try response.map { try $0.toDomain() }
    }

    func createListing(draft: CreateListingRequest) async throws -> SnowboardListing {
        let response: ListingResponse = try await send(
            path: "/listings",
            method: .post,
            body: draft,
            requiresAuth: true
        )
        return try response.toDomain()
    }

    func logout() {
        cachedToken = nil
        tokenStore.saveToken(nil)
    }

    // MARK: - Internal helpers

    private func send<Response: Decodable>(
        path: String,
        method: HTTPMethod,
        requiresAuth: Bool
    ) async throws -> Response {
        let empty: EmptyBody? = nil
        return try await send(path: path, method: method, body: empty, requiresAuth: requiresAuth)
    }

    private func send<Body: Encodable, Response: Decodable>(
        path: String,
        method: HTTPMethod,
        body: Body? = nil,
        requiresAuth: Bool
    ) async throws -> Response {
        var request = try makeRequest(path: path, method: method, requiresAuth: requiresAuth)

        if let body {
            do {
                request.httpBody = try encoder.encode(body)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                throw APIError.encoding(error)
            }
        }

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            guard (200..<300).contains(httpResponse.statusCode) else {
                throw APIError.httpStatus(httpResponse.statusCode, data)
            }

            do {
                return try decoder.decode(Response.self, from: data)
            } catch {
                throw APIError.decoding(error)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.transport(error)
        }
    }

    private func makeRequest(path: String, method: HTTPMethod, requiresAuth: Bool) throws -> URLRequest {
        guard var components = URLComponents(url: configuration.baseURL, resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }

        let trimmed = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        components.path = components.path.appending("/\(trimmed)")
        guard let url = components.url else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if requiresAuth {
            guard let token = cachedToken ?? tokenStore.loadToken() else {
                throw APIError.missingToken
            }
            cachedToken = token
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        return request
    }
}

// MARK: - DTOs

private struct EmptyBody: Encodable {}

private struct LoginRequest: Encodable {
    let email: String
    let password: String
}

private struct RegisterRequest: Encodable {
    let email: String
    let password: String
    let displayName: String
}

private struct AuthResponse: Decodable {
    let token: String
    let user: UserResponse

    func toDomain() throws -> APIClient.AuthSession {
        APIClient.AuthSession(token: token, user: try user.toDomain())
    }
}

private struct UserResponse: Decodable {
    let userId: UUID
    let email: String
    let displayName: String
    let location: String?
    let bio: String?
    let rating: Double?
    let dealsCount: Int?

    func toDomain() throws -> APIClient.AuthenticatedUser {
        APIClient.AuthenticatedUser(
            userID: userId,
            email: email,
            displayName: displayName,
            location: location ?? "",
            bio: bio ?? "",
            rating: rating ?? 0,
            dealsCount: dealsCount ?? 0
        )
    }
}

struct CreateListingRequest: Encodable {
    let title: String
    let description: String
    let condition: String
    let price: Double
    let location: String
    let tradeOption: String
    let isFavorite: Bool
    let imageUrl: String?

    init(
        title: String,
        description: String,
        condition: SnowboardListing.Condition,
        price: Double,
        location: String,
        tradeOption: SnowboardListing.TradeOption,
        isFavorite: Bool = false,
        imageUrl: String? = nil
    ) {
        self.title = title
        self.description = description
        self.condition = condition.apiValue
        self.price = price
        self.location = location
        self.tradeOption = tradeOption.apiValue
        self.isFavorite = isFavorite
        self.imageUrl = imageUrl
    }
}

private struct ListingResponse: Decodable {
    struct Seller: Decodable {
        let sellerId: UUID
        let displayName: String
        let rating: Double?
        let dealsCount: Int?
    }

    let listingId: UUID
    let title: String
    let description: String
    let condition: String
    let price: Double
    let location: String
    let tradeOption: String
    let isFavorite: Bool?
    let imageUrl: String?
    let seller: Seller

    func toDomain() throws -> SnowboardListing {
        guard let conditionValue = SnowboardListing.Condition(apiValue: condition) else {
            throw APIClient.APIError.domain("Unknown condition value: \(condition)")
        }
        guard let tradeValue = SnowboardListing.TradeOption(apiValue: tradeOption) else {
            throw APIClient.APIError.domain("Unknown trade option: \(tradeOption)")
        }

        let sellerModel = SnowboardListing.Seller(
            id: seller.sellerId,
            nickname: seller.displayName,
            rating: seller.rating ?? 0,
            dealsCount: seller.dealsCount ?? 0
        )

        return SnowboardListing(
            id: listingId,
            title: title,
            description: description,
            condition: conditionValue,
            price: price,
            location: location,
            tradeOption: tradeValue,
            isFavorite: isFavorite ?? false,
            imageName: imageUrl ?? "",
            photos: [],
            seller: sellerModel
        )
    }
}
