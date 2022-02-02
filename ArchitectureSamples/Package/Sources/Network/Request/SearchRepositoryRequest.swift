//
//  SearchRepositoryRequest.swift
//
//  Created by kntk on 2021/10/24.
//

import Moya
import Foundation

import Model

public enum GitHubRepositorySortKind {
    case stars
    case forks
    case helpWantedIssues
    case updated
    case bestMatch

    var rawValue: String? {
        switch self {
        case .stars: return "stars"
        case .forks: return "forks"
        case .helpWantedIssues: return "help-wanted-issues"
        case .updated: return "updated"
        case .bestMatch: return nil
        }
    }
}

public struct SearchGitHubRepositoryResponse: Codable {
    public var items: [GitHubRepository]
}

public struct SearchGitHubRepositoryRequest {

    public var query: String
    public var sort: GitHubRepositorySortKind

    public init(query: String, sort: GitHubRepositorySortKind) {
        self.query = query
        self.sort = sort
    }
}

extension SearchGitHubRepositoryRequest: APITargetType {

    public typealias Response = SearchGitHubRepositoryResponse

    public var path: String {
        return "/search/repositories"
    }

    public var method: Moya.Method {
        return .get
    }

    public var task: Task {
        var parameters: Parameters = [
            "q": query
        ]

        if let sortKind = sort.rawValue {
            parameters["sort"] = sortKind
        }

        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }

    public var sampleData: Data {
        let path = Bundle.main.path(forResource: "SearchGitHubRepositoryRequestStub", ofType: "json")!
        return FileHandle(forReadingAtPath: path)!.readDataToEndOfFile()
    }
}
