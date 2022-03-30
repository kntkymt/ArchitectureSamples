//
//  ViewController.swift
//  Fat
//
//  Created by kntk on 2022/02/03.
//

import UIKit
import ReSwift
import RxSwift

import PresentationCommon

final class MainViewController: UINavigationController, Storyboardable {

    // MARK: - Build

    static func build() -> Self {
        return initViewController()
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let viewModel = RepositorySearchViewModelImpl(store: AppContainer.shared.store, state: AppContainer.shared.store.stateObservable.map { $0.repositorySearchState }, gitHubRepositorySearchUsecase: AppContainer.shared.gitHubRepositorySearchUsecase)
        let viewController = RepositorySearchViewController.build(viewModel: viewModel)
        setViewControllers([viewController], animated: false)
    }
}
