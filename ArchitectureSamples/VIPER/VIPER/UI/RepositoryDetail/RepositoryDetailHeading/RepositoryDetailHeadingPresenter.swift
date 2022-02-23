//
//  GitHubRepositoryDetailPresenter.swift
//
//  Created by kntk on 2021/10/24.
//

import Foundation

import Model

final class RepositoryDetailHeadingPresenter: RepositoryDetailHeadingPresentation {

    // MARK: - Property

    private weak var view: RepositoryDetailHeadingView?
    private let router: RepositoryDetailHeadingWireframe

    private let gitHubRepository: GitHubRepository

    // MARK: - Initializer

    init(view: RepositoryDetailHeadingView, gitHubRepository: GitHubRepository, router: RepositoryDetailHeadingWireframe) {
        self.view = view
        self.gitHubRepository = gitHubRepository
        self.router = router
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
