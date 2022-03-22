//
//  AppContainer.swift
//  MVVM_RX
//
//  Created by kntk on 2022/02/24.
//

import Foundation

final class AppContainer {

    // MARK: - Static

    static var shared: AppContainer!

    // MARK: - Property

    let gitHubRepositorySearchUsecase: GitHubRepositorySearchUsecase

    // MARK: - Public

    static func setup(gitHubRepositorySearchUsecase: GitHubRepositorySearchUsecase) {
        self.shared = AppContainer(gitHubRepositorySearchUsecase: gitHubRepositorySearchUsecase)
    }

    // MARK: - Initializer

    private init(gitHubRepositorySearchUsecase: GitHubRepositorySearchUsecase) {
        self.gitHubRepositorySearchUsecase = gitHubRepositorySearchUsecase
    }
}
