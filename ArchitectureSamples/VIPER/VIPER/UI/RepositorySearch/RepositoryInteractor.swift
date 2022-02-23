//
//  RepositoryInteractor.swift
//  VIPER
//
//  Created by kntk on 2022/02/24.
//

import Foundation

import Repository
import Model

final class RepositorySearchInteractor {

    // MARK: - Property

    private let repository: GitHubRepositoryRepository

    // MARK: - Initializer

    init(repository: GitHubRepositoryRepository) {
        self.repository = repository
    }
}

extension RepositorySearchInteractor: RepositorySearchUsecase {

    func searchGitHubRepositories(by searchText: String) async throws -> [GitHubRepository] {
        return try await repository.searchGitHubRepositories(by: searchText, sort: .bestMatch)
    }

    func getTrendingGitHubRepositories() async throws -> [GitHubRepository] {
        return try await repository.searchGitHubRepositories(by: "Swift", sort: .stars)
    }
}
