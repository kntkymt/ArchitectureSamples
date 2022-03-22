//
//  RepositoryDetailCountViewModel.swift
//  MVVM_RX
//
//  Created by kntk on 2022/02/24.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

import Model

protocol RepositoryDetailCountViewModel {

    var gitHubRepository: Driver<GitHubRepository> { get }
}

final class RepositoryDetailCountViewModelImpl: RepositoryDetailCountViewModel {

    private let repositoryDetailStore: RepositoryDetailStore
    private let repositoryDetailActionCreator: RepositoryDetailActionCreator

    var gitHubRepository: Driver<GitHubRepository>

    init(repositoryDetailStore: RepositoryDetailStore, repositoryDetailActionCreator: RepositoryDetailActionCreator) {
        self.repositoryDetailStore = repositoryDetailStore
        self.repositoryDetailActionCreator = repositoryDetailActionCreator

        self.gitHubRepository = repositoryDetailStore.gitHubRepository
            .asDriver(onErrorDriveWith: .empty())
    }
}
