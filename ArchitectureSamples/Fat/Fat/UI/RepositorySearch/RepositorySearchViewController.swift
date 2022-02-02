//
//  RepositorySearchViewController.swift
//  Fat
//
//  Created by kntk on 2022/02/03.
//

import UIKit

import AppError
import Loging
import PresentationCommon
import Usecase
import Model
import AppContainer

final class RepositorySearchViewController: UIViewController, Storyboardable, BannerShowable {

    // MARK: - Outlet

    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }

    // MARK: - Property

    private var showErrorView = false
    private var showEmptyView = false

    private var gitHubRepositorySearchUsecase: GitHubReposiotySearchUsecase!
    private var gitHubRepositories: [GitHubRepository] = []

    // 非検索状態で表示される「おすすめ」的な立ち位置のリポジトリ一覧
    private var initialGitHubRepositories: [GitHubRepository]?

    private var searchText = ""

    private var searchTask: Task<Void, Error>?

    private lazy var searchController: UISearchController = {
            let searchController = UISearchController()
            searchController.searchBar.delegate = self
            searchController.searchBar.placeholder = "GitHubのリポジトリを検索"

            return searchController
        }()

        private lazy var indicatorView: UIActivityIndicatorView = {
            let indicatorView = UIActivityIndicatorView()
            indicatorView.style = .large
            indicatorView.color = .systemGray
            indicatorView.backgroundColor = .clear
            indicatorView.frame.size.height = 50
            indicatorView.hidesWhenStopped = true

            return indicatorView
        }()

        private lazy var emptyViewController = EmptyViewController.build(emptyTitle: "リポジトリがありません")
        private lazy var errorViewController = ErrorViewController.build(refreshTitle: "再読み込み", hideRefreshButton: false)

    // MARK: - Build

    static func build(gitHubRepositorySearchUsecase: GitHubReposiotySearchUsecase) -> Self {
        let viewController = initViewController()
        viewController.gitHubRepositorySearchUsecase = gitHubRepositorySearchUsecase
        return viewController
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.addSubview(indicatorView, constraints: .center())

        tableView.register(RepositoryTableViewCell.self)

        title = "検索"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        errorViewController.setRefreshButtonHandler { [weak self] in
            if self?.initialGitHubRepositories == nil {
                self?.setInitialGitHubRepositories()
            } else {
                self?.searchGitHubRepositories()
            }
        }

        setInitialGitHubRepositories()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.indexPathsForSelectedRows?.forEach {
            tableView.deselectRow(at: $0, animated: true)
        }
    }

    // MARK: - Private

    private func searchGitHubRepositories() {
        indicatorView.startAnimating()
        tableView.isUserInteractionEnabled = false

        searchTask = Task {
            do {
                self.gitHubRepositories = try await gitHubRepositorySearchUsecase.searchGitHubRepositories(by: searchText)
                showEmptyView = self.gitHubRepositories.isEmpty
                showErrorView = false

                indicatorView.stopAnimating()
                tableView.isUserInteractionEnabled = true

                tableView.reloadData()
                tableView.scrollToTop(animated: false)
            } catch {
                self.gitHubRepositories = []
                showErrorView = true

                indicatorView.stopAnimating()
                tableView.isUserInteractionEnabled = true

                tableView.reloadData()

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

            tableView.reloadData()
            tableView.scrollToTop(animated: false)
        } else {
            indicatorView.startAnimating()
            tableView.isUserInteractionEnabled = false

            searchTask = Task {
                do {
                    let initialGitHubRepositories = try await gitHubRepositorySearchUsecase.getTrendingGitHubRepositories()
                    self.initialGitHubRepositories = initialGitHubRepositories
                    gitHubRepositories = initialGitHubRepositories

                    showEmptyView = gitHubRepositories.isEmpty
                    showErrorView = false

                    indicatorView.stopAnimating()
                    tableView.isUserInteractionEnabled = true
                    tableView.reloadData()
                    tableView.scrollToTop(animated: false)
                } catch {
                    showErrorView = true

                    indicatorView.stopAnimating()
                    tableView.isUserInteractionEnabled = true
                    tableView.reloadData()

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

        showErrorBanner(title, with: message)
    }
}

// MARK: - UITableViewDataSource

extension RepositorySearchViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gitHubRepositories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let gitHubRepository = gitHubRepositories[indexPath.row]

        return tableView.dequeue(RepositoryTableViewCell.self, for: indexPath, with: gitHubRepository)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if showErrorView {
            return errorViewController.view
        } else if showEmptyView {
            return emptyViewController.view
        } else {
            return nil
        }
    }
}

// MARK: - UITableViewDelegate

extension RepositorySearchViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let gitHubRepository = gitHubRepositories[indexPath.row]
        let detailHeadingViewController = RepositoryDetailHeadingViewController.build(gitHubRepository: gitHubRepository)

        let detailCountViewController = RepositoryDetailCountViewController.build(gitHubRepository: gitHubRepository)

        let detailViewController = RepositoryDetailViewController.build(headingViewController: detailHeadingViewController,
                                                                              countViewController: detailCountViewController,
                                                                              gitHubRepository: gitHubRepository)
        navigationController?.pushViewController(detailViewController, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return showEmptyView || showErrorView ? tableView.bounds.height : CGFloat.leastNormalMagnitude
    }
}

// MARK: - UISearchBarDelegate

extension RepositorySearchViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        searchTask?.cancel()

        indicatorView.stopAnimating()
        tableView.isUserInteractionEnabled = true
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchGitHubRepositories()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchTask?.cancel()
        setInitialGitHubRepositories()
    }
}
