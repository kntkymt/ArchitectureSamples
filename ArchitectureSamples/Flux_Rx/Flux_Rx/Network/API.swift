//
//  API.swift
//  MVVM_RX
//
//  Created by kntk on 2022/02/24.
//

import Moya
import RxMoya
import RxSwift

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

    func call<R: APITargetType>(_ request: R) -> Single<R.Response> {
        let target = MultiTarget(request)
        return provider.rx.request(target)
            .filterSuccessfulStatusCodes()
            .catch { Single.error(self.createError(from: $0 as! MoyaError)) }
            .flatMap {
                do {
                    return Single.just(try request.decode(from: $0))
                } catch {
                    return Single.error(APIError.decode(error))
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
