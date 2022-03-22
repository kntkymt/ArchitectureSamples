//
//  RepositorySeachActionCreator.swift
//  Flux_Rx
//
//  Created by kntk on 2022/03/22.
//

import Foundation
import RxSwift

import Model
import Loging

// ViewModelからの要求を処理してActionを発行し、Dispatcherに渡す
final class RepositorySearchActionCreator {

    // MARK: - Property

    private let gitHubRepositorySearchUsecase: GitHubRepositorySearchUsecase
    private let dispatcher: RepositorySearchDispatcher

    private var disposeBag = DisposeBag()

    // MARK: - Initializer

    init(gitHubRepositorySearchUsecase: GitHubRepositorySearchUsecase, dispatcher: RepositorySearchDispatcher) {
        self.gitHubRepositorySearchUsecase = gitHubRepositorySearchUsecase
        self.dispatcher = dispatcher
    }

    // MARK: - Public

    func setSearchText(_ searchText: String) {
        dispatcher.setSearchText.accept(searchText)
    }

    func searchGitHubRepositories(by searchText: String) {
        dispatcher.setIsLoading.accept(true)

        gitHubRepositorySearchUsecase.searchGitHubRepositories(by: searchText)
            .subscribe(onSuccess: { repositories in
                self.dispatcher.setError.accept(nil)
                self.dispatcher.setGitHubRepositories.accept(repositories)

                self.dispatcher.setIsLoading.accept(false)
            }, onFailure: { error in
                self.dispatcher.setGitHubRepositories.accept([])

                Logger.error(error)
                self.dispatcher.setError.accept(error)

                self.dispatcher.setIsLoading.accept(false)
            })
            .disposed(by: disposeBag)
    }

    func setGitHubRepositories(repositories: [GitHubRepository]) {
        dispatcher.setGitHubRepositories.accept(repositories)
        dispatcher.setError.accept(nil)
    }

    func fetchInitialGitHubRepositories() {
        dispatcher.setIsLoading.accept(true)
        
        gitHubRepositorySearchUsecase.getTrendingGitHubRepositories()
            .subscribe(onSuccess: { repositories in
                self.dispatcher.setError.accept(nil)
                self.dispatcher.setInitialGitHubRepositories.accept(repositories)
                self.dispatcher.setGitHubRepositories.accept(repositories)

                self.dispatcher.setIsLoading.accept(false)
            }, onFailure: { error in
                Logger.error(error)
                self.dispatcher.setIsLoading.accept(false)
            })
            .disposed(by: disposeBag)
    }
}
