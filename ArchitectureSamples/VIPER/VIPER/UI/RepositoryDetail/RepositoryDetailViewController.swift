//
//  GitHubRepositoryDetailViewController.swift
//
//  Created by kntk on 2021/10/25.
//

import Foundation
import UIKit

import Model
import PresentationCommon

final class RepositoryDetailViewController: VStackViewController, Storyboardable, WebViewShowable {

    // MARK: - Property

    var gitHubRepository: GitHubRepository!

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
