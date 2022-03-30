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

    private let store: RxStore
    private let state: Observable<RepositoryDetailState>

    var gitHubRepository: Driver<GitHubRepository> = .empty()

    init(store: RxStore, state: Observable<RepositoryDetailState>) {
        self.store = store
        self.state = state

        self.gitHubRepository = state.map { $0.repository }.asDriver(onErrorDriveWith: .empty())
    }
}
