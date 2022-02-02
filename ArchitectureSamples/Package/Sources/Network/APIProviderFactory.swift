//
//  APIProviderFactory.swift
//
//  Created by kntk on 2021/10/24.
//

import Moya
import Alamofire
import Foundation

public enum APIProviderFactory {

    // MARK: - Property

    private static let configuration: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = HTTPHeaders.default.dictionary
        configuration.timeoutIntervalForRequest = 30

        return configuration
    }()

    // MARK: - Public

    /// サーバーへ向けたProvider生成する
    public static func createService() -> MoyaProvider<MultiTarget> {
        return createProvider()
    }

    // MARK: - Private

    /// Interceptorを元にProviderを作成
    private static func createProvider(stubBehavior: @escaping (MultiTarget) -> StubBehavior = MoyaProvider.neverStub) -> MoyaProvider<MultiTarget> {
        let sessionManager = Session(configuration: configuration)

        let provider = MoyaProvider<MultiTarget>(stubClosure: stubBehavior,
                                                 session: sessionManager,
                                                 plugins: [LoggerPlugin()])

        return provider
    }
}
