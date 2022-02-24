//
//  RepositoryDetailHeadingViewModel.swift
//  MVVM_RX
//
//  Created by kntk on 2022/02/24.
//

import Foundation
import RxSwift
import RxRelay

import Model

protocol RepositoryDetailHeadingViewModel {

    var gitHubRepository: BehaviorRelay<GitHubRepository> { get }

    init(gitHubRepository: GitHubRepository)
}

final class RepositoryDetailHeadingViewModelImpl: RepositoryDetailHeadingViewModel {

    var gitHubRepository: BehaviorRelay<GitHubRepository>

    init(gitHubRepository: GitHubRepository) {
        self.gitHubRepository = .init(value: gitHubRepository)
    }
}
