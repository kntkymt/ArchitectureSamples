//
//  RepositoryDetailViewController.swift
//
//

import UIKit

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

    private var gitHubRepository: GitHubRepository!

    // MARK: - Build

    static func build(gitHubRepository: GitHubRepository) -> Self {
        let viewController = initViewController()
        viewController.gitHubRepository = gitHubRepository
        return viewController
    }

    // MARK: - Lifecycle
        
    override func viewDidLoad() {
        super.viewDidLoad()

        showDetail()
    }

    // MARK: - Private

    private func showDetail() {
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
