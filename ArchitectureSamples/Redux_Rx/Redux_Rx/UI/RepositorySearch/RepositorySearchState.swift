//
//  RepositorySearchState.swift
//  Redux_Rx
//
//  Created by kntk on 2022/03/30.
//

import Foundation
import RxSwift
import ReSwift

import Loging
import Model

// MARK: - State

struct RepositorySearchState {

    private(set) var searchText: String = ""
    private(set) var isLoading: Bool = false
    private(set) var initialGitHubRepositories: [GitHubRepository]? = nil
    private(set) var gitHubRepositories: [GitHubRepository] = []
    private(set) var error: Error? = nil

}

// MARK: - Action

extension RepositorySearchState {
    enum Action: ReSwift.Action {

        typealias RequestActionCreator = (
            _ state: AppState,
            _ store: DispatchingStoreType
            ) -> Void

        case setSearchText(String)
        case setIsLoading(Bool)
        case setInitialGitHubRepositories([GitHubRepository]?)
        case setGitHubRepositories([GitHubRepository])
        case setError(Error?)

        static func searchGitHubRepositoriesAsyncCreator(by searchText: String, usecase: GitHubRepositorySearchUsecase, disposeBag: RxSwift.DisposeBag) -> RequestActionCreator {
            return { state, store in
                store.dispatch(Action.setIsLoading(true))

                usecase.searchGitHubRepositories(by: searchText)
                    .subscribe(onSuccess: { repositories in
                        store.dispatch(Action.setError(nil))
                        store.dispatch(Action.setGitHubRepositories(repositories))

                        store.dispatch(Action.setIsLoading(false))
                    }, onFailure: { error in
                        store.dispatch(Action.setGitHubRepositories([]))

                        Logger.error(error)
                        store.dispatch(Action.setError(error))
                        store.dispatch(Action.setIsLoading(false))
                    })
                    .disposed(by: disposeBag)
            }
        }

        static func fetchInitialGitHubRepositories(usecase: GitHubRepositorySearchUsecase, disposeBag: RxSwift.DisposeBag) -> RequestActionCreator {
            return { state, store in
                store.dispatch(Action.setIsLoading(true))

                usecase.getTrendingGitHubRepositories()
                    .subscribe(onSuccess: { repositories in
                        store.dispatch(Action.setError(nil))
                        store.dispatch(Action.setInitialGitHubRepositories(repositories))
                        store.dispatch(Action.setGitHubRepositories(repositories))

                        store.dispatch(Action.setIsLoading(false))
                    }, onFailure: { error in
                        Logger.error(error)

                        store.dispatch(Action.setIsLoading(false))
                    })
                    .disposed(by: disposeBag)
            }
        }
    }
}

// MARK: - Reducer

extension RepositorySearchState {
    
    static func reducer(action: ReSwift.Action, state: Self) -> Self {
        var state = state

        switch action {
        case let action as RepositorySearchState.Action:
            switch action {
            case .setSearchText(let searchText):
                state.searchText = searchText

            case .setIsLoading(let isLoading):
                state.isLoading = isLoading

            case .setInitialGitHubRepositories(let repositories):
                state.initialGitHubRepositories = repositories

            case .setGitHubRepositories(let repositories):
                state.gitHubRepositories = repositories

            case .setError(let error):
                state.error = error
            }

        default:
            break
        }

        return state
    }
}
