//
//  RepositorySeachStore.swift
//  Flux_Rx
//
//  Created by kntk on 2022/03/22.
//

import Foundation
import RxRelay
import RxCocoa
import RxSwift

import Model

// StoreはDispatcherから流れてくるアクションに応じて状態を変化させるだけ
// 本当はRxProperty等を用いてRead-Onlyで公開できると良い、ViewModelからStoreを直接変更できてしまうため
final class RepositorySearchStore {

    // MARK: - Property

    let searchText: BehaviorRelay<String> = .init(value: "")

    let isLoading: BehaviorRelay<Bool> = .init(value: false)

    let initialGitHubRepositories: BehaviorRelay<[GitHubRepository]?> = .init(value: nil)

    let gitHubRepositories: BehaviorRelay<[GitHubRepository]> = .init(value: [])

    let error: BehaviorRelay<Error?> = .init(value: nil)

    private var disposeBag = DisposeBag()

    // MARK: - Initializer

    init(dispatcher: RepositorySearchDispatcher) {
        dispatcher.setSearchText
            .bind(to: searchText)
            .disposed(by: disposeBag)

        dispatcher.setIsLoading
            .bind(to: isLoading)
            .disposed(by: disposeBag)

        dispatcher.setInitialGitHubRepositories
            .bind(to: initialGitHubRepositories)
            .disposed(by: disposeBag)

        dispatcher.setGitHubRepositories
            .bind(to: gitHubRepositories)
            .disposed(by: disposeBag)

        dispatcher.setError
            .bind(to: error)
            .disposed(by: disposeBag)
    }
}
