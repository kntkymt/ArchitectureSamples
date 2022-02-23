//
//  RepositoryDetailHeadingRouter.swift
//  VIPER
//
//  Created by kntk on 2022/02/23.
//

import Foundation

import Model

final class RepositoryDetailHeadingRouter {

    // MARK: - Property

    private var viewController: RepositoryDetailHeadingViewController!

    // MARK: - Initializer

    init(viewController: RepositoryDetailHeadingViewController) {
        self.viewController = viewController
    }

    // MARK: - Assemble

    static func assembleModules(gitHubRepository: GitHubRepository) -> RepositoryDetailHeadingViewController {
        let viewController = RepositoryDetailHeadingViewController.initViewController()

        let router = RepositoryDetailHeadingRouter(viewController: viewController)
        viewController.presenter = RepositoryDetailHeadingPresenter(view: viewController, gitHubRepository: gitHubRepository, router: router)

        return viewController
    }
}

extension RepositoryDetailHeadingRouter: RepositoryDetailHeadingWireframe {

}
