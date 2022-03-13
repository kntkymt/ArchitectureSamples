//
//  GitHubRepositoryRepository.swift
//  MVVM_RX
//
//  Created by kntk on 2022/02/24.
//

import Foundation
import ReactiveSwift

import Model

protocol GitHubRepositoryRepository {

    /// 指定された検索語でGitHubのリポジトリを検索する
    ///
    /// - parameters:
    ///     - word: 検索語
    ///     - sort: 検索結果のソート方法
    /// - returns: 検索結果
    func searchGitHubRepositories(by word: String, sort: GitHubRepositorySortKind) -> SignalProducer<[GitHubRepository], Error>
}

final class GitHubRepositoryRepositoryImpl: GitHubRepositoryRepository {

    func searchGitHubRepositories(by word: String, sort: GitHubRepositorySortKind) -> SignalProducer<[GitHubRepository], Error> {
        return API.shared.call(SearchGitHubRepositoryRequest(query: word, sort: sort)).map { $0.items }
    }

    init() {}
}
