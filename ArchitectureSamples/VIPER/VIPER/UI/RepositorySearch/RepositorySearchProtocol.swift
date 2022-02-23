//
//  RepositorySearchProtocol.swift
//
//  Created by kntk on 2021/10/24.
//

import PresentationCommon
import Model

protocol RepositorySearchView: AnyObject, BannerShowable {

    /// TablewViewのロード表示をする
    func showTableViewLoading()

    /// TableViewのロード表示を隠す
    func hideTableViewLoading()

    /// TableViewを最上部までスクロールする
    ///
    /// - parameters:
    ///     - animated: アニメーションをするかどうか
    func tableViewScrollToTop(animated: Bool)

    /// TableViewをリロードする
    func tableViewReloadData()
}

protocol RepositorySearchPresentation: Presentation {

    /// ErrorViewを表示するかどうか
    var showErrorView: Bool { get }

    /// EmptyViewを表示するかどうか
    var showEmptyView: Bool { get }

    /// GitHubのリポジトリの数
    var gitHubRepositoriesCount: Int { get }

    /// 指定されたindexのGitHubRepositoryを返す
    ///
    /// - parameters:
    ///     - index: 指定するindex
    /// - Returns: 指定されたGitHubRepository
    func gitHubRepository(at index: Int) -> GitHubRepository

    /// TableViewがselectされた
    ///
    /// - parameters:
    ///     - index: selectされたindex
    func tableViewDidSelectRow(at index: Int)

    /// 検索ボタンが押された
    func searchBarSearchButtonDidTap()

    /// キャンセルボタンが押された
    func searchBarCancelButtonDidTap()

    /// 検索文字が変更された
    /// 
    /// - parameters:
    ///     - searchText: 検索語
    func searchBarSearchTextDidChange(searchText: String)

    /// ErroViewのリフレッシュボタンが押された
    func errorViewRefreshButtonDidTap()
}

protocol RepositorySearchWireframe: AnyObject {

    /// 詳細画面に遷移する
    ///
    /// - parameters:
    ///     - repository: 詳細を表示するGitHubのリポジトリ
    func pushToDetailView(gitHubRepository: GitHubRepository)
}

protocol RepositorySearchUsecase: AnyObject {

    func searchGitHubRepositories(by searchText: String) async throws -> [GitHubRepository]

    func getTrendingGitHubRepositories() async throws -> [GitHubRepository]
}
