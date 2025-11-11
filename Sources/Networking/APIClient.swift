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
        // ⚠️ 后端需要提供统一的 /api 前缀，例如 http://localhost:8080/api，
        // 才能匹配这里构造出来的请求 URL。部署到线上时请将域名替换到 baseURL。
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

    struct SocialGraph: Hashable {
        let followingSellerIDs: Set<UUID>
        let followersOfCurrentUser: Set<UUID>
    }

    struct AuthenticatedUser: Hashable {
        let userID: UUID
        let email: String
        let displayName: String
        let location: String
        let bio: String
        let rating: Double
        let dealsCount: Int
        let socialGraph: SocialGraph
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
        // 说明：前端发送的 JSON 使用 snake_case，例如 display_name。
        // 后端的 DTO（例如 LoginRequest）字段也要遵循 snake_case 才能正确接收。
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        // 说明：后端返回 JSON 时同样要使用 snake_case，例如 user_id、listing_id。
        // 这样才能映射到模型字段。
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    func login(email: String, password: String) async throws -> AuthSession {
        // 对应后端接口：POST /api/auth/login，Body: {"email": "...", "password": "..."}
        // 后端需返回形如 {"token": "JWT", "user": {...}} 的 JSON。
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
        // 对应后端接口：POST /api/auth/register，Body: {"email", "password", "display_name"}
        // 成功后同样返回 token + user 信息，便于前端直接进入登录态。
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
        // 对应后端接口：GET /api/auth/me，需要校验 Authorization: Bearer <token>
        // 返回当前登录用户信息，字段参考 UserResponse。
        let response: UserResponse = try await send(
            path: "/auth/me",
            method: .get,
            requiresAuth: true
        )
        return try response.toDomain()
    }

    func fetchListings() async throws -> [SnowboardListing] {
        // 对应后端接口：GET /api/listings，需校验 JWT。
        // 后端返回数组，每个元素含 listing_id、title、seller 信息等。
        let response: [ListingResponse] = try await send(
            path: "/listings",
            method: .get,
            requiresAuth: true
        )
        return try response.map { try $0.toDomain() }
    }

    func fetchSocialGraph() async throws -> SocialGraph {
        // 对应后端接口：GET /api/social/graph，返回当前用户的关注与粉丝 ID 列表。
        // 关注成功后群聊、私信等逻辑才能正确判断互相关注。
        let response: SocialGraphResponse = try await send(
            path: "/social/graph",
            method: .get,
            requiresAuth: true
        )
        return response.toDomain()
    }

    func followSeller(_ sellerID: UUID) async throws -> SocialGraph {
        // 对应后端接口：POST /api/social/follows，Body: {"seller_id": "..."}
        // 有些实现返回 204 No Content，因此这里在拿不到响应体时会回退到 GET /api/social/graph。
        let request = FollowRequest(sellerId: sellerID)
        if let response: SocialGraphResponse = try await sendAllowingEmpty(
            path: "/social/follows",
            method: .post,
            body: request,
            requiresAuth: true
        ) {
            return response.toDomain()
        }
        return try await fetchSocialGraph()
    }

    func unfollowSeller(_ sellerID: UUID) async throws -> SocialGraph {
        // 对应后端接口：DELETE /api/social/follows/{seller_id}
        // 如果服务器仅返回状态码，同样回退到拉取完整社交图谱，保证前端状态刷新。
        if let response: SocialGraphResponse = try await sendAllowingEmpty(
            path: "/social/follows/\(sellerID.uuidString)",
            method: .delete,
            body: EmptyBody(),
            requiresAuth: true
        ) {
            return response.toDomain()
        }
        return try await fetchSocialGraph()
    }

    func createListing(draft: CreateListingRequest) async throws -> SnowboardListing {
        // 对应后端接口：POST /api/listings，Body 为 CreateListingRequest。
        // 后端应根据 JWT 中用户信息设置 seller，并返回创建后的 listing 数据。
        let response: ListingResponse = try await send(
            path: "/listings",
            method: .post,
            body: draft,
            requiresAuth: true
        )
        return try response.toDomain()
    }

    func fetchTrips() async throws -> [GroupTrip] {
        // 对应后端接口：GET /api/trips，返回当前可见的组团行程列表。
        let response: [TripResponse] = try await send(
            path: "/trips",
            method: .get,
            requiresAuth: true
        )
        return try response.map { try $0.toDomain() }
    }

    func createTrip(draft: CreateTripRequest) async throws -> GroupTrip {
        // 对应后端接口：POST /api/trips，Body 为 CreateTripRequest。
        // 服务端需根据 JWT 解析组织者身份，并返回持久化后的行程实体。
        let response: TripResponse = try await send(
            path: "/trips",
            method: .post,
            body: draft,
            requiresAuth: true
        )
        return try response.toDomain()
    }

    func favoriteListing(_ listingID: UUID) async throws -> SnowboardListing? {
        // 对应后端接口：POST /api/listings/{listing_id}/favorite。
        // 如果后端返回 204，这里会返回 nil，调用方应刷新列表或自行合并本地状态。
        if let response: ListingResponse = try await sendAllowingEmpty(
            path: "/listings/\(listingID.uuidString)/favorite",
            method: .post,
            body: EmptyBody(),
            requiresAuth: true
        ) {
            return try response.toDomain()
        }
        return nil
    }

    func unfavoriteListing(_ listingID: UUID) async throws -> SnowboardListing? {
        // 对应后端接口：DELETE /api/listings/{listing_id}/favorite。
        // 如果服务器仅返回状态码，这里会返回 nil，调用方需要后续刷新。
        if let response: ListingResponse = try await sendAllowingEmpty(
            path: "/listings/\(listingID.uuidString)/favorite",
            method: .delete,
            body: EmptyBody(),
            requiresAuth: true
        ) {
            return try response.toDomain()
        }
        return nil
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
                if let message = decodeErrorMessage(from: data), !message.isEmpty {
                    throw APIError.domain(message)
                }
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

    private func sendAllowingEmpty<Body: Encodable, Response: Decodable>(
        path: String,
        method: HTTPMethod,
        body: Body? = nil,
        requiresAuth: Bool
    ) async throws -> Response? {
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
                if let message = decodeErrorMessage(from: data), !message.isEmpty {
                    throw APIError.domain(message)
                }
                throw APIError.httpStatus(httpResponse.statusCode, data)
            }

            guard !data.isEmpty else { return nil }

            do {
                return try decoder.decode(Response.self, from: data)
            } catch is DecodingError {
                // 如果后端仅返回简单的成功消息或布尔值，这里允许回退到调用方
                // 的兜底逻辑（例如重新拉取社交图谱或列表），以保持兼容性。
                return nil
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
            // 说明：后续所有需要鉴权的接口，前端会自动带上 Authorization 头。
            // 后端需通过 Spring Security 的 JWT 过滤器解析并校验。
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        return request
    }

    private func decodeErrorMessage(from data: Data) -> String? {
        guard !data.isEmpty else { return nil }
        return (try? decoder.decode(ErrorEnvelope.self, from: data))?.message
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
    let followingSellerIds: [UUID]?
    let followersOfCurrentUser: [UUID]?

    func toDomain() throws -> APIClient.AuthenticatedUser {
        let socialGraph = APIClient.SocialGraph(
            followingSellerIDs: Set(followingSellerIds ?? []),
            followersOfCurrentUser: Set(followersOfCurrentUser ?? [])
        )
        return APIClient.AuthenticatedUser(    // ✅ 添加 return
            userID: userId,
            email: email,
            displayName: displayName,
            location: location ?? "",
            bio: bio ?? "",
            rating: rating ?? 0,
            dealsCount: dealsCount ?? 0,
            socialGraph: socialGraph
        )
    }

}

private struct FollowRequest: Encodable {
    let sellerId: UUID
}

private struct SocialGraphResponse: Decodable {
    let followingSellerIds: [UUID]
    let followersOfCurrentUser: [UUID]

    func toDomain() -> APIClient.SocialGraph {
        APIClient.SocialGraph(
            followingSellerIDs: Set(followingSellerIds),
            followersOfCurrentUser: Set(followersOfCurrentUser)
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
        // 后端 CreateListingRequest DTO 示例（Java 记录/类均可）：
        // public record CreateListingRequest(String title, String description, String condition,
        //     BigDecimal price, String location, String trade_option,
        //     Boolean is_favorite, String image_url) {}
        // 注意字段使用 snake_case（例如 trade_option、image_url）以配合前端编码策略。
    }
}

struct CreateTripRequest: Encodable {
    let title: String
    let resort: String
    let departureLocation: String
    let startDate: Date
    let minimumParticipants: Int
    let maximumParticipants: Int
    let estimatedCostPerPerson: Double
    let description: String
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

private struct TripResponse: Decodable {
    struct Organizer: Decodable {
        let sellerId: UUID
        let displayName: String
        let rating: Double?
        let dealsCount: Int?
    }

    struct JoinRequest: Decodable {
        let requestId: UUID
        let applicant: Organizer
        let requestedAt: Date
    }

    let tripId: UUID
    let title: String
    let resort: String
    let departureLocation: String
    let startDate: Date
    let minimumParticipants: Int
    let maximumParticipants: Int
    let estimatedCostPerPerson: Double
    let description: String
    let organizer: Organizer
    let approvedParticipantIds: [UUID]?
    let pendingRequests: [JoinRequest]?

    func toDomain() throws -> GroupTrip {
        guard minimumParticipants <= maximumParticipants else {
            throw APIClient.APIError.domain("Trip minimum participants exceeds maximum: \(minimumParticipants) > \(maximumParticipants)")
        }

        let organizerModel = SnowboardListing.Seller(
            id: organizer.sellerId,
            nickname: organizer.displayName,
            rating: organizer.rating ?? 0,
            dealsCount: organizer.dealsCount ?? 0
        )

        let requests = (pendingRequests ?? []).map { request in
            GroupTrip.JoinRequest(
                id: request.requestId,
                applicant: SnowboardListing.Seller(
                    id: request.applicant.sellerId,
                    nickname: request.applicant.displayName,
                    rating: request.applicant.rating ?? 0,
                    dealsCount: request.applicant.dealsCount ?? 0
                ),
                requestedAt: request.requestedAt
            )
        }

        return GroupTrip(
            id: tripId,
            title: title,
            resort: resort,
            departureLocation: departureLocation,
            startDate: startDate,
            participantRange: minimumParticipants...maximumParticipants,
            estimatedCostPerPerson: estimatedCostPerPerson,
            description: description,
            organizer: organizerModel,
            approvedParticipantIDs: Set(approvedParticipantIds ?? []),
            pendingRequests: requests
        )
    }
}

private struct ErrorEnvelope: Decodable {
    let message: String?
}
