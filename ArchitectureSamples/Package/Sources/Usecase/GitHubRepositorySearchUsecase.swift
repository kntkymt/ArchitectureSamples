//
//  GitHubRepositorySearchUsecase.swift
//
//  Created by kntk on 2021/10/24.
//

import Model
import Repository

public protocol GitHubReposiotySearchUsecase {

    /// 指定された検索語でGitHubのリポジトリを検索する
    ///
    /// - parameters:
    ///     - word: 検索語
    /// - returns: 検索結果
    func searchGitHubRepositories(by word: String) async throws -> [GitHubRepository]

    /// GitHubのリポジトリのトレンドを取得する
    ///
    /// - returns: トレンドのGitHubリポジトリ
    func getTrendingGitHubRepositories() async throws -> [GitHubRepository]
}

public final class GitHubRepositorySearchUsecaseImpl: GitHubReposiotySearchUsecase {

    // MARK: - Property

    private let gitHubRepositoryRepository: GitHubRepositoryRepository

    // MARK: - Initializer

    public init(gitHubRepositoryRepository: GitHubRepositoryRepository) {
        self.gitHubRepositoryRepository = gitHubRepositoryRepository
    }

    // MARK: - Internal

    public func searchGitHubRepositories(by word: String) async throws -> [GitHubRepository] {
        return try await gitHubRepositoryRepository.searchGitHubRepositories(by: word, sort: .bestMatch)
    }

    // FIXME: トレンドAPI
    // トレンド的な良さげなレポジトリを返してくれるAPIがほしかったが、
    // なかったので現状はSwiftで検索したもので代用中
    public func getTrendingGitHubRepositories() async throws -> [GitHubRepository] {
        return try await gitHubRepositoryRepository.searchGitHubRepositories(by: "Swift", sort: .stars)
    }
}
