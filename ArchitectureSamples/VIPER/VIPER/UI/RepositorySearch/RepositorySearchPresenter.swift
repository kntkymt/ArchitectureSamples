//
//  GitHubRepositorySearchPresenter.swift
//
//  Created by kntk on 2021/10/24.
//

import Foundation

import PresentationCommon
import Model
import Loging
import AppError

final class RepositorySearchPresenter: RepositorySearchPresentation {

    // MARK: - Property

    private weak var view: RepositorySearchView?

    var showErrorView = false
    var showEmptyView = false

    var gitHubRepositoriesCount: Int {
        return gitHubRepositories.count
    }

    private let gitHubRepositorySearchUsecase: RepositorySearchUsecase
    private let gitHubRepositorySearchWireframe: RepositorySearchWireframe
    private var gitHubRepositories: [GitHubRepository] = []

    // 非検索状態で表示される「おすすめ」的な立ち位置のリポジトリ一覧
    private var initialGitHubRepositories: [GitHubRepository]?

    private var searchText = ""

    private var searchTask: Task<Void, Error>?

    // MARK: - Initializer

    init(view: RepositorySearchView, gitHubRepositorySearchUsecase: RepositorySearchUsecase, gitHubRepositorySearchWireframe: RepositorySearchWireframe) {
        self.view = view
        self.gitHubRepositorySearchUsecase = gitHubRepositorySearchUsecase
        self.gitHubRepositorySearchWireframe = gitHubRepositorySearchWireframe
    }

    // MARK: - Lifecycle

    func viewDidLoad() {
        setInitialGitHubRepositories()
    }

    func viewWillAppear() {
    }

    func viewDidAppear() {
    }

    func viewDidStop() {
    }

    func gitHubRepository(at index: Int) -> GitHubRepository {
        return gitHubRepositories[index]
    }

    func tableViewDidSelectRow(at index: Int) {
        DispatchQueue.main.async {
            self.gitHubRepositorySearchWireframe.pushToDetailView(gitHubRepository: self.gitHubRepositories[index])
        }
    }

    func searchBarSearchButtonDidTap() {
        searchGitHubRepositories()
    }

    func searchBarCancelButtonDidTap() {
        searchTask?.cancel()
        setInitialGitHubRepositories()
    }

    func searchBarSearchTextDidChange(searchText: String) {
        self.searchText = searchText
        searchTask?.cancel()
        DispatchQueue.main.async { [weak self] in
            self?.view?.hideTableViewLoading()
        }
    }

    func errorViewRefreshButtonDidTap() {
        if initialGitHubRepositories == nil {
            setInitialGitHubRepositories()
        } else {
            searchGitHubRepositories()
        }
    }

    // MARK: - Private

    private func searchGitHubRepositories() {
        DispatchQueue.main.async { [weak self] in
            self?.view?.showTableViewLoading()
        }

        searchTask = Task {
            do {
                self.gitHubRepositories = try await gitHubRepositorySearchUsecase.searchGitHubRepositories(by: searchText)
                showEmptyView = self.gitHubRepositories.isEmpty
                showErrorView = false

                DispatchQueue.main.async { [weak self] in
                    self?.view?.hideTableViewLoading()
                    self?.view?.tableViewReloadData()
                    self?.view?.tableViewScrollToTop(animated: false)
                }
            } catch {
                self.gitHubRepositories = []
                showErrorView = true

                DispatchQueue.main.async { [weak self] in
                    self?.view?.hideTableViewLoading()
                    self?.view?.tableViewReloadData()
                }

                Logger.error(error)
                handle(error)
            }
        }
    }

    private func setInitialGitHubRepositories() {
        // 既に取得してある場合は使い回す
        if let initialGitHubRepositories = initialGitHubRepositories {
            gitHubRepositories = initialGitHubRepositories
            showEmptyView = gitHubRepositories.isEmpty
            showErrorView = false

            DispatchQueue.main.async { [weak self] in
                self?.view?.tableViewReloadData()
                self?.view?.tableViewScrollToTop(animated: false)
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.view?.showTableViewLoading()
            }

            searchTask = Task {
                do {
                    let initialGitHubRepositories = try await gitHubRepositorySearchUsecase.getTrendingGitHubRepositories()
                    self.initialGitHubRepositories = initialGitHubRepositories
                    gitHubRepositories = initialGitHubRepositories

                    showEmptyView = gitHubRepositories.isEmpty
                    showErrorView = false

                    DispatchQueue.main.async { [weak self] in
                        self?.view?.hideTableViewLoading()
                        self?.view?.tableViewReloadData()
                        self?.view?.tableViewScrollToTop(animated: false)
                    }
                } catch {
                    showErrorView = true

                    DispatchQueue.main.async { [weak self] in
                        self?.view?.hideTableViewLoading()
                        self?.view?.tableViewReloadData()
                    }

                    Logger.error(error)
                    handle(error)
                }
            }
        }
    }

    private func handle(_ error: Error) {

        let title: String
        let message: String

        if let apiErorr = error as? APIError {
            switch apiErorr {
            case .statusCode(let statusCodeError):
                if case .validationFailed = statusCodeError {
                    title = "バリデーションエラー"
                    message = "入力に利用できない文字が含まれています。\n入力を変更して再度お試しください。\n\(statusCodeError._domain), \(statusCodeError._code)"
                } else {
                    title = "システムエラー"
                    message = "再度お試しください。\n\(statusCodeError._domain), \(statusCodeError._code)"
                }

            case .response(let error):
                title = "ネットワークエラー"
                message = "通信状況をお確かめの上、再度お試しください。\n\(error._domain), \(error._code)"

            case .decode(let error):
                title = "パースエラー"
                message = "再度お試しください。\n\(error._domain), \(error._code)"

            case .base64Decode:
                title = "パースエラー"
                message = "再度お試しください。\n\(error._domain), \(error._code)"
            }
        } else {
            title = "システムエラー"
            message = "再度お試しください。\n\(error._domain), \(error._code)"
        }

        DispatchQueue.main.async { [weak self] in
            self?.view?.showErrorBanner(title, with: message)
        }
    }
}
