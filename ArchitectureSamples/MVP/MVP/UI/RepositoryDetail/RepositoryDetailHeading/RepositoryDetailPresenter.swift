//
//  GitHubRepositoryDetailPresenter.swift
//
//  Created by kntk on 2021/10/24.
//

import Foundation

import Model

final class GitHubRepositoryDetailHeadingPresenter: RepositoryDetailHeadingPresentation {

    // MARK: - Property

    private weak var view: RepositoryDetailHeadingView?

    private let gitHubRepository: GitHubRepository

    // MARK: - Initializer

    init(view: RepositoryDetailHeadingView, gitHubRepository: GitHubRepository) {
        self.view = view
        self.gitHubRepository = gitHubRepository
    }

    // MARK: - Lifecycle

    func viewDidLoad() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.view?.showGitHubRepositoryDetailHeading(gitHubRepository: self.gitHubRepository)
        }
    }

    func viewWillAppear() {
    }

    func viewDidAppear() {
    }

    func viewDidStop() {
    }
}
