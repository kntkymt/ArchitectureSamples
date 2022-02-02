//
//  GitHubRepositoryRepository.swift
//
//  Created by kntk on 2021/10/24.
//

import Model
import Network

public protocol GitHubRepositoryRepository {

    /// 指定された検索語でGitHubのリポジトリを検索する
    ///
    /// - parameters:
    ///     - word: 検索語
    ///     - sort: 検索結果のソート方法
    /// - returns: 検索結果
    func searchGitHubRepositories(by word: String, sort: GitHubRepositorySortKind) async throws -> [GitHubRepository]
}


public final class GitHubRepositoryRepositoryImpl: GitHubRepositoryRepository {

    public func searchGitHubRepositories(by word: String, sort: GitHubRepositorySortKind) async throws -> [GitHubRepository] {
        return try await API.shared.call(SearchGitHubRepositoryRequest(query: word, sort: sort)).items
    }

    public init() {}
}
