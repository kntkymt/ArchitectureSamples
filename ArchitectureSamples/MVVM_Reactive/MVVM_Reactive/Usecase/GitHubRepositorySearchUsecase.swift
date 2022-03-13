//
//  GitHubRepositorySearchUsecase.swift
//  MVVM_RX
//
//  Created by kntk on 2022/02/24.
//

import Foundation
import ReactiveSwift

import Model

protocol GitHubRepositorySearchUsecase {

    /// 指定された検索語でGitHubのリポジトリを検索する
    ///
    /// - parameters:
    ///     - word: 検索語
    /// - returns: 検索結果
    func searchGitHubRepositories(by word: String) -> SignalProducer<[GitHubRepository], Error>

    /// GitHubのリポジトリのトレンドを取得する
    ///
    /// - returns: トレンドのGitHubリポジトリ
    func getTrendingGitHubRepositories() -> SignalProducer<[GitHubRepository], Error>
}

final class GitHubRepositorySearchUsecaseImpl: GitHubRepositorySearchUsecase {

    // MARK: - Property

    private let gitHubRepositoryRepository: GitHubRepositoryRepository

    // MARK: - Initializer

    init(gitHubRepositoryRepository: GitHubRepositoryRepository) {
        self.gitHubRepositoryRepository = gitHubRepositoryRepository
    }

    // MARK: - Internal

    func searchGitHubRepositories(by word: String) -> SignalProducer<[GitHubRepository], Error> {
        return gitHubRepositoryRepository.searchGitHubRepositories(by: word, sort: .bestMatch)
    }

    // FIXME: トレンドAPI
    // トレンド的な良さげなレポジトリを返してくれるAPIがほしかったが、
    // なかったので現状はSwiftで検索したもので代用中
    func getTrendingGitHubRepositories() -> SignalProducer<[GitHubRepository], Error> {
        return gitHubRepositoryRepository.searchGitHubRepositories(by: "Swift", sort: .stars)
    }
}
