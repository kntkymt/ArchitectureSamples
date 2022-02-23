//
//  RepositorySearchRouter.swift
//  VIPER
//
//  Created by kntk on 2022/02/23.
//

import Foundation

import Model
import UIKit
import AppRepositoryContainer

final class RepositorySearchRouter {

    // MARK: - Property

    private weak var viewController: RepositorySearchViewController?

    // MARK: - Initializer

    init(viewController: RepositorySearchViewController) {
        self.viewController = viewController
    }

    // MARK: - Assemble

    static func assembleModules() -> RepositorySearchViewController {
        let viewController = RepositorySearchViewController.initViewController()

        let router = RepositorySearchRouter(viewController: viewController)
        let interactor = RepositorySearchInteractor(repository: AppRepositoryContainer.shared.gitHubRepositoryRepository)

        viewController.presenter = RepositorySearchPresenter(view: viewController,
                                                             gitHubRepositorySearchUsecase: interactor,
                                                             gitHubRepositorySearchWireframe: router)

        return viewController
    }
}

extension RepositorySearchRouter: RepositorySearchWireframe {

    func pushToDetailView(gitHubRepository: GitHubRepository) {
        let detailViewController = RepositoryDetailRouter.assembleModules(gitHubRepository: gitHubRepository)

        viewController?.navigationController?.pushViewController(detailViewController, animated: true)
    }
}
