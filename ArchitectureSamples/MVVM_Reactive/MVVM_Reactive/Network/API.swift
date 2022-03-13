//
//  API.swift
//  MVVM_RX
//
//  Created by kntk on 2022/02/24.
//

import Moya
import ReactiveMoya
import ReactiveSwift

import AppError

final class API {

    // MARK: - Static

    static private(set) var shared: API!

    // MARK: - Property

    private let provider: MoyaProvider<MultiTarget>

    // MARK: - Public

    static func setup(provider: MoyaProvider<MultiTarget>) {
        self.shared = API(provider: provider)
    }

    func call<R: APITargetType>(_ request: R) -> SignalProducer<R.Response, Error> {
        let target = MultiTarget(request)
        return provider.reactive.request(target)
            .filterSuccessfulStatusCodes()
            .mapError { self.createError(from: $0) }
            .attemptMap { response in
                Result {
                    try request.decode(from: response)
                }.mapError { APIError.decode($0) }
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
