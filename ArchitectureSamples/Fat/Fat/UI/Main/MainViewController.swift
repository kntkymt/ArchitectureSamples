//
//  ViewController.swift
//  Fat
//
//  Created by kntk on 2022/02/03.
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

        let viewController = RepositorySearchViewController.build(gitHubRepositorySearchUsecase: AppContainer.shared.gitHubRepositorySearchUsecase)
        setViewControllers([viewController], animated: false)
    }
}
