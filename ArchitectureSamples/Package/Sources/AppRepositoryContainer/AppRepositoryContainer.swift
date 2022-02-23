//
//  File.swift
//  
//
//  Created by kntk on 2022/02/24.
//

import Repository

public final class AppRepositoryContainer {

    // MARK: - Static

    public static var shared: AppRepositoryContainer!

    // MARK: - Property

    public let gitHubRepositoryRepository: GitHubRepositoryRepository

    // MARK: - Public

    public static func setup(gitHubRepositoryRepository: GitHubRepositoryRepository) {
        self.shared = AppRepositoryContainer(gitHubRepositoryRepository: gitHubRepositoryRepository)
    }

    // MARK: - Initializer

    private init(gitHubRepositoryRepository: GitHubRepositoryRepository) {
        self.gitHubRepositoryRepository = gitHubRepositoryRepository
    }
}
