//
//  RepositoryDetailCountRouter.swift
//  VIPER
//
//  Created by kntk on 2022/02/23.
//

import Foundation

import Model

final class RepositoryDetailCountRouter {

    // MARK: - Property

    private weak var viewController: RepositoryDetailCountViewController?

    // MARK: - Initializer

    init(viewController: RepositoryDetailCountViewController) {
        self.viewController = viewController
    }

    // MARK: - Assemble

    static func assembleModules(gitHubRepository: GitHubRepository) -> RepositoryDetailCountViewController {
        let viewController = RepositoryDetailCountViewController.initViewController()

        let router = RepositoryDetailCountRouter(viewController: viewController)

        viewController.presenter = RepositoryDetailCountPresenter(view: viewController, gitHubRepository: gitHubRepository, router: router)

        return viewController
    }
}

extension RepositoryDetailCountRouter: RepositoryDetailCountWireframe {

}
