//
//  RepositoryDetailRouter.swift
//  VIPER
//
//  Created by kntk on 2022/02/23.
//

import Foundation

import Model

final class RepositoryDetailRouter {

    // MARK: - Property

    private weak var viewController: RepositoryDetailViewController?

    // MARK: - Initializer

    init(viewController: RepositoryDetailViewController) {
        self.viewController = viewController
    }

    // MARK: - Assemble

    static func assembleModules(gitHubRepository: GitHubRepository) -> RepositoryDetailViewController {
        let viewController = RepositoryDetailViewController.initViewController()

        let headingViewController = RepositoryDetailHeadingRouter.assembleModules(gitHubRepository: gitHubRepository)
        let countViewController = RepositoryDetailCountRouter.assembleModules(gitHubRepository: gitHubRepository)

        viewController.components = [
            headingViewController,
            countViewController,
        ]

        viewController.gitHubRepository = gitHubRepository

        return viewController
    }
}

extension RepositoryDetailRouter: RepositoryDetailWireframe {
}
