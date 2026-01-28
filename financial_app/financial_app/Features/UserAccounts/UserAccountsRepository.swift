import Combine
import Foundation

protocol UserAccountsRepository {
    func accounts(forceRefresh: Bool) -> AnyPublisher<[Account], APIError>
    func invalidateCache()
}

final class DefaultUserAccountsRepository: UserAccountsRepository {
    static let shared = DefaultUserAccountsRepository()
    
    private let apiService: APIServicing
    private let cacheTTL: TimeInterval?
    private var cachedAccounts: [Account]?
    private var lastFetched: Date?
    private var inFlight: AnyPublisher<[Account], APIError>?
    private let lock = NSLock()

    init(apiService: APIServicing = APIService.shared, cacheTTL: TimeInterval? = nil) {
        self.apiService = apiService
        self.cacheTTL = cacheTTL
    }

    func accounts(forceRefresh: Bool) -> AnyPublisher<[Account], APIError> {
        // Fast path: return cache if valid and not forcing refresh
        if let cached = cachedAccounts, !forceRefresh, !isCacheStale() {
            return Just(cached)
                .setFailureType(to: APIError.self)
                .eraseToAnyPublisher()
        }

        // If a request is already in flight, reuse it.
        if let shared = withLock({ inFlight }) {
            return shared
        }

        // Start a new request and share it.
        let publisher: AnyPublisher<[Account], APIError> = apiService
            .request(endpoint: .userAccounts)
            .handleEvents(receiveOutput: { [weak self] accounts in
                self?.withLock {
                    self?.cachedAccounts = accounts
                    self?.lastFetched = Date()
                }
            }, receiveCompletion: { [weak self] _ in
                self?.withLock { self?.inFlight = nil }
            }, receiveCancel: { [weak self] in
                self?.withLock { self?.inFlight = nil }
            })
            .share()
            .eraseToAnyPublisher()

        withLock { inFlight = publisher }
        return publisher
    }

    func invalidateCache() {
        withLock {
            cachedAccounts = nil
            lastFetched = nil
        }
    }

    private func isCacheStale() -> Bool {
        guard let ttl = cacheTTL else { return false }
        guard let last = lastFetched else { return true }
        return Date().timeIntervalSince(last) > ttl
    }

    @discardableResult
    private func withLock<T>(_ block: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return block()
    }
}
