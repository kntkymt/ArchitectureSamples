//
//  GitHubRepositoryDetailCountViewController.swift
//
//  Created by kntk on 2021/10/25.
//

import UIKit
import ReactiveSwift

import PresentationCommon
import Model

final class RepositoryDetailCountViewController: UITableViewController, Storyboardable {

    // MARK: - Outlet

    @IBOutlet private weak var starIconImageBackgroundView: UIView! {
        didSet {
            starIconImageBackgroundView.layer.cornerRadius = 4.0
        }
    }
    @IBOutlet private weak var starCountLabel: UILabel!

    @IBOutlet private weak var watcherIconImageBackgroundView: UIView! {
        didSet {
            watcherIconImageBackgroundView.layer.cornerRadius = 4.0
        }
    }
    @IBOutlet private weak var watcherCountLabel: UILabel!

    @IBOutlet private weak var forkIconImageBackgroundView: UIView! {
        didSet {
            forkIconImageBackgroundView.layer.cornerRadius = 4.0
        }
    }
    @IBOutlet private weak var forkCountLabel: UILabel!

    @IBOutlet private weak var issueIconImageBackgroundView: UIView! {
        didSet {
            issueIconImageBackgroundView.layer.cornerRadius = 4.0
        }
    }
    @IBOutlet private weak var issueCountLabel: UILabel!

    // MARK: - Property

    private var viewModel: RepositoryDetailCountViewModel!
    private var disposeBag = CompositeDisposable()

    // MARK: - Build

    static func build(viewModel: RepositoryDetailCountViewModel) -> Self {
        let viewController = initViewController()
        viewController.viewModel = viewModel
        return viewController
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.heightAnchor.constraint(equalToConstant: 240).isActive = true

        disposeBag.add(viewModel.gitHubRepository
                        .producer
                        .startWithValues { [weak self] gitHubRepository in
                            self?.showDetail(gitHubRepository: gitHubRepository)
                        })
    }

    // MARK: - Private

    private func showDetail(gitHubRepository: GitHubRepository) {
        starCountLabel.text = String.localizedStringWithFormat("%d", gitHubRepository.stargazersCount)
        watcherCountLabel.text = String.localizedStringWithFormat("%d", gitHubRepository.watchersCount)
        forkCountLabel.text = String.localizedStringWithFormat("%d", gitHubRepository.forksCount)
        issueCountLabel.text = String.localizedStringWithFormat("%d", gitHubRepository.openIssuesCount)
    }
}
