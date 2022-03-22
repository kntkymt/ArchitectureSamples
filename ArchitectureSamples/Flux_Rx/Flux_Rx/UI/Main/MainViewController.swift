//
//  ViewController.swift
//  Fat
//
//  Created by kntk on 2022/02/03.
//

import UIKit

import PresentationCommon

final class MainViewController: UINavigationController, Storyboardable {

    // MARK: - Build

    static func build() -> Self {
        return initViewController()
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let dispatcher = RepositorySearchDispatcher()
        let store = RepositorySearchStore(dispatcher: dispatcher)
        let actionCreator = RepositorySearchActionCreator(gitHubRepositorySearchUsecase: AppContainer.shared.gitHubRepositorySearchUsecase, dispatcher: dispatcher)

        let viewModel = RepositorySearchViewModelImpl(repositorySeachStore: store,
                                                      repositorySeachActionCreator: actionCreator)
        let viewController = RepositorySearchViewController.build(viewModel: viewModel)
        setViewControllers([viewController], animated: false)
    }
}
