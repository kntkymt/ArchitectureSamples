//
//  RepositoryDetailCountViewModel.swift
//  MVVM_RX
//
//  Created by kntk on 2022/02/24.
//

import Foundation
import ReactiveSwift

import Model

protocol RepositoryDetailCountViewModel {

    var gitHubRepository: Property<GitHubRepository> { get }

    init(gitHubRepository: GitHubRepository)
}

final class RepositoryDetailCountViewModelImpl: RepositoryDetailCountViewModel {

    var gitHubRepository: Property<GitHubRepository>

    init(gitHubRepository: GitHubRepository) {
        self.gitHubRepository = .init(value: gitHubRepository)
    }
}

