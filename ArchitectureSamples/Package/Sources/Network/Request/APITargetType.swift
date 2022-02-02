//
//  APITargetType.swift
//
//  Created by kntk on 2021/10/24.
//

import Moya
import Foundation

import Constant

typealias Parameters = [String: Any]

public protocol APITargetType: TargetType {
    associatedtype Response: Codable

    func decode(from result: Moya.Response) throws -> Response
}

public extension APITargetType {
    
    var baseURL: URL {
        return URL(string: AppConstant.API.baseURL)!
    }

    var headers: [String: String]? {
        return ["Accept": "application/vnd.github.v3+json"]
    }

    func decode(from result: Moya.Response) throws -> Response {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(Response.self, from: result.data)
    }
}
