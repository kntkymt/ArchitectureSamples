//
//  RepositorySearchDispatcher.swift
//  Flux_Rx
//
//  Created by kntk on 2022/03/22.
//

import Foundation

import Model
import RxRelay

// 各パラメーターがActionとなっている
// ActionはStoreへの変更を表すのが良い(?)
// 他にもaddGitHubRepositories, removeGitHubRepositoriesなど
final class RepositorySearchDispatcher {

    let setSearchText: PublishRelay<String> = .init()
    let setIsLoading: PublishRelay<Bool> = .init()
    let setInitialGitHubRepositories: PublishRelay<[GitHubRepository]?> = .init()
    let setGitHubRepositories: PublishRelay<[GitHubRepository]> = .init()
    let setError: PublishRelay<Error?> = .init()
}
