//
//  GitHubRepositoryDetailCountPresenter.swift
//
//  Created by kntk on 2021/10/25.
//

import Foundation

import Model

final class RepositoryDetailCountPresenter: RepositoryDetailCountPresentation {

    // MARK: - Property

    private weak var view: RepositoryDetailCountView?

    private var gitHubRepository: GitHubRepository

    // MARK: - Initializer

    init(view: RepositoryDetailCountView, gitHubRepository: GitHubRepository) {
        self.view = view
        self.gitHubRepository = gitHubRepository
    }

    // MARK: - Lifecycle

    func viewDidLoad() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.view?.showGitHubRepositoryDetailCount(gitHubRepository: self.gitHubRepository)
        }
    }

    func viewWillAppear() {
    }

    func viewDidAppear() {
    }

    func viewDidStop() {
    }
}
