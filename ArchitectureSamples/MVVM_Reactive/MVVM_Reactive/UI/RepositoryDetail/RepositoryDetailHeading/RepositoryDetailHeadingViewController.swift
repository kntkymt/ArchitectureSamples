//
//  RepositoryDetailViewController.swift
//
//

import UIKit
import ReactiveSwift

import PresentationCommon
import Model

final class RepositoryDetailHeadingViewController: UIViewController, Storyboardable {

    // MARK: - Outlet
    
    @IBOutlet private weak var iconImageView: UIImageView!
    
    @IBOutlet private weak var ownerNameLabel: UILabel!
    @IBOutlet private weak var repositoryNameLabel: UILabel!
    @IBOutlet private weak var repositoryDescriptionLabel: UILabel!
    @IBOutlet private weak var languageLabel: UILabel!

    // MARK: - Property

    private var viewModel: RepositoryDetailHeadingViewModel!
    private var disposeBag = CompositeDisposable()

    // MARK: - Build

    static func build(viewModel: RepositoryDetailHeadingViewModel) -> Self {
        let viewController = initViewController()
        viewController.viewModel = viewModel
        return viewController
    }

    // MARK: - Lifecycle
        
    override func viewDidLoad() {
        super.viewDidLoad()

        disposeBag.add(viewModel.gitHubRepository
            .producer
            .startWithValues { [weak self] gitHubRepository in
            self?.showDetail(gitHubRepository: gitHubRepository)
        })
    }

    // MARK: - Private

    private func showDetail(gitHubRepository: GitHubRepository) {
        iconImageView.load(gitHubRepository.owner.avatarUrl)

        ownerNameLabel.text = gitHubRepository.owner.login
        repositoryNameLabel.text = gitHubRepository.name
        if let description = gitHubRepository.description {
            repositoryDescriptionLabel.isHidden = false
            repositoryDescriptionLabel.text = description
        } else {
            repositoryDescriptionLabel.isHidden = true
            repositoryDescriptionLabel.text = ""
        }

        if let language = gitHubRepository.language {
            languageLabel.isHidden = false
            languageLabel.text = "Written in \(language)"
        } else {
            languageLabel.isHidden = true
            languageLabel.text = ""
        }
    }
}
