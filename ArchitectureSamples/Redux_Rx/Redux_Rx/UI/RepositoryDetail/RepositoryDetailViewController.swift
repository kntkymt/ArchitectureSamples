//
//  GitHubRepositoryDetailViewController.swift
//
//  Created by kntk on 2021/10/25.
//

import UIKit

import PresentationCommon
import Model

final class RepositoryDetailViewController: VStackViewController, Storyboardable, WebViewShowable {

    // MARK: - Property

    private var gitHubRepository: GitHubRepository!

    // MARK: - Build

    static func build(
        headingViewController: RepositoryDetailHeadingViewController,
        countViewController: RepositoryDetailCountViewController,
        gitHubRepository: GitHubRepository
    ) -> Self {
        let viewController = initViewController()

        viewController.components = [
            headingViewController,
            countViewController
        ]

        viewController.gitHubRepository = gitHubRepository

        return viewController
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = false
        title = gitHubRepository.name
    }

    // MARK: - Action

    @IBAction private func shareButtonDidTap(_ sender: Any) {
        let activityViewController = UIActivityViewController(activityItems: [gitHubRepository.htmlUrl], applicationActivities: [])
        present(activityViewController, animated: true)
    }
}
