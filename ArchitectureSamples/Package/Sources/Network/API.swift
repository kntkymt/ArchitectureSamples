//
//  API.swift
//
//  Created by kntk on 2021/10/24.
//

import Moya
import Foundation

import AppError

public final class API {

    // MARK: - Static

    public static private(set) var shared: API!

    // MARK: - Property

    private let provider: MoyaProvider<MultiTarget>

    // MARK: - Public

    public static func setup(provider: MoyaProvider<MultiTarget>) {
        self.shared = API(provider: provider)
    }

    public func call<R: APITargetType>(_ request: R) async throws -> R.Response {
        return try await withCheckedThrowingContinuation { continuation in
            let target = MultiTarget(request)
            self.provider.request(target) { response in
                // 200番台以外をfailureにする
                let result = response.flatMap { old in
                    // swiftlint:disable:next force_cast
                    Swift.Result { try old.filterSuccessfulStatusCodes() }.mapError { $0 as! MoyaError }
                }

                switch result {
                case .success(let result):
                    do {
                        continuation.resume(returning: try request.decode(from: result))
                    } catch {
                        continuation.resume(throwing: APIError.decode(error))
                    }

                case .failure(let error):
                    continuation.resume(throwing: self.createError(from: error))

                }
            }
        }
    }

    // MARK: - Private

    private func createError(from error: MoyaError) -> Error {
        switch error {
        case .statusCode(let response):
            return APIError.statusCode(.init(statusCode: response.statusCode))

        case .underlying(let underlyingError, _):
            // underlyingの場合は情報量がないので展開して返す
            return APIError.response(underlyingError)

        default:
            return APIError.response(error)
        }
    }

    // MARK: - Initializer

    private init(provider: MoyaProvider<MultiTarget>) {
        self.provider = provider
    }
}
