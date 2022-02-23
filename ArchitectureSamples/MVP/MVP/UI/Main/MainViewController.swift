//
//  MainViewController.swift
//
//  Created by kntk on 2021/10/23.
//

import UIKit

import PresentationCommon
import AppContainer

final class MainViewController: UINavigationController, Storyboardable {

    // MARK: - Build

    static func build() -> Self {
        return initViewController()
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let viewController = RepositorySearchViewController.build()
        viewController.presenter = RepositorySearchPresenter(view: viewController, gitHubRepositorySearchUsecase: AppContainer.shared.gitHubRepositorySearchUsecase)
        setViewControllers([viewController], animated: false)
    }
}
