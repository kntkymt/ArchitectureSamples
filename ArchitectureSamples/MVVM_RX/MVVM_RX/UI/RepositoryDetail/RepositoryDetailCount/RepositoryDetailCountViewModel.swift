//
//  RepositoryDetailCountViewModel.swift
//  MVVM_RX
//
//  Created by kntk on 2022/02/24.
//

import Foundation
import RxSwift
import RxRelay

import Model

protocol RepositoryDetailCountViewModel {

    var gitHubRepository: BehaviorRelay<GitHubRepository> { get }

    init(gitHubRepository: GitHubRepository)
}

final class RepositoryDetailCountViewModelImpl: RepositoryDetailCountViewModel {

    var gitHubRepository: BehaviorRelay<GitHubRepository>

    init(gitHubRepository: GitHubRepository) {
        self.gitHubRepository = .init(value: gitHubRepository)
    }
}

