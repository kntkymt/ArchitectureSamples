//
//  AppContainer.swift
//  MVVM_RX
//
//  Created by kntk on 2022/02/24.
//

import Foundation
import ReSwift

final class AppContainer {

    // MARK: - Static

    static var shared: AppContainer!

    // MARK: - Property

    let store: RxStore
    let gitHubRepositorySearchUsecase: GitHubRepositorySearchUsecase

    // MARK: - Public

    static func setup(store: RxStore, gitHubRepositorySearchUsecase: GitHubRepositorySearchUsecase) {
        self.shared = AppContainer(store: store, gitHubRepositorySearchUsecase: gitHubRepositorySearchUsecase)
    }

    // MARK: - Initializer

    private init(store: RxStore, gitHubRepositorySearchUsecase: GitHubRepositorySearchUsecase) {
        self.store = store
        self.gitHubRepositorySearchUsecase = gitHubRepositorySearchUsecase
    }
}
