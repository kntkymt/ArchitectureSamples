//
//  AppContainer.swift
//  
//
//  Created by kntk on 2022/02/03.
//

import Usecase

public final class AppContainer {

    // MARK: - Static

    public static var shared: AppContainer!

    // MARK: - Property

    public let gitHubRepositorySearchUsecase: GitHubReposiotySearchUsecase

    // MARK: - Public

    public static func setup(gitHubRepositorySearchUsecase: GitHubReposiotySearchUsecase) {
        self.shared = AppContainer(gitHubRepositorySearchUsecase: gitHubRepositorySearchUsecase)
    }

    // MARK: - Initializer

    private init(gitHubRepositorySearchUsecase: GitHubReposiotySearchUsecase) {
        self.gitHubRepositorySearchUsecase = gitHubRepositorySearchUsecase
    }
}

