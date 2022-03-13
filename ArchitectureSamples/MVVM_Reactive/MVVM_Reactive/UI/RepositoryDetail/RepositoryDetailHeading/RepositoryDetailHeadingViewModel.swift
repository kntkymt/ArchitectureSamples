//
//  RepositoryDetailHeadingViewModel.swift
//  MVVM_RX
//
//  Created by kntk on 2022/02/24.
//

import Foundation
import ReactiveSwift

import Model

protocol RepositoryDetailHeadingViewModel {

    var gitHubRepository: Property<GitHubRepository> { get }

    init(gitHubRepository: GitHubRepository)
}

final class RepositoryDetailHeadingViewModelImpl: RepositoryDetailHeadingViewModel {

    var gitHubRepository: Property<GitHubRepository>

    init(gitHubRepository: GitHubRepository) {
        self.gitHubRepository = .init(value: gitHubRepository)
    }
}
