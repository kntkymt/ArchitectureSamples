//
//  RepositorySearchViewController.swift
//  Fat
//
//  Created by kntk on 2022/02/03.
//

import UIKit
import RxSwift
import RxCocoa

import AppError
import Loging
import PresentationCommon
import Model

final class RepositorySearchViewController: UIViewController, Storyboardable, BannerShowable {

    // MARK: - Outlet

    @IBOutlet private weak var tableView: UITableView!

    // MARK: - Property

    var items: [GitHubRepository] = []

    private var disposeBag = DisposeBag()

    private var viewModel: RepositorySearchViewModel!

    private lazy var searchController: UISearchController = {
            let searchController = UISearchController()
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

    static func build(viewModel: RepositorySearchViewModel) -> Self {
        let viewController = initViewController()
        viewController.viewModel = viewModel

        return viewController
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.searchText
            .asDriver()
            .drive(searchController.searchBar.searchTextField.rx.text)
            .disposed(by: disposeBag)

        searchController.searchBar.searchTextField.rx.text
            .orEmpty
            .asDriver()
            .drive(viewModel.searchText)
            .disposed(by: disposeBag)

        viewModel.isLoading
            .asDriver()
            .drive(indicatorView.rx.isAnimating)
            .disposed(by: disposeBag)

        viewModel.isLoading
            .asDriver()
            .map { !$0 }
            .drive(tableView.rx.isUserInteractionEnabled)
            .disposed(by: disposeBag)

        viewModel.error
            .asDriver()
            .flatMap { $0.flatMap(Driver.just) ?? Driver.empty() }
            .drive(onNext: { [weak self] title, message in
                self?.showErrorBanner(title, with: message)
            })
            .disposed(by: disposeBag)

        viewModel.gitHubRepositories
            .asDriver()
            .drive(tableView.rx.items) { tableView, row, element in
                tableView.dequeue(RepositoryTableViewCell.self, for: IndexPath(row: row, section: 0), with: element)
            }
            .disposed(by: disposeBag)

        // 以下ロジックが混ざっているのでよう修正
        // viewModel側にinputを作ってそこにbindし、viewmodel側でsearchを呼ぶべき？
        searchController.searchBar.rx.searchButtonClicked
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.viewModel.searchGitHubRepositories()
            })
            .disposed(by: disposeBag)

        searchController.searchBar.rx.cancelButtonClicked
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.viewModel.setInitialGitHubRepositories()
            })
            .disposed(by: disposeBag)

        tableView.rx.itemSelected
            .asDriver()
            .drive(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                let gitHubRepository = self.viewModel.gitHubRepositories.value[indexPath.row]
                let detailHeadingViewController = RepositoryDetailHeadingViewController.build(viewModel: RepositoryDetailHeadingViewModelImpl(gitHubRepository: gitHubRepository))

                let detailCountViewController = RepositoryDetailCountViewController.build(viewModel: RepositoryDetailCountViewModelImpl(gitHubRepository: gitHubRepository))

                let detailViewController = RepositoryDetailViewController.build(headingViewController: detailHeadingViewController,
                                                                                      countViewController: detailCountViewController,
                                                                                      gitHubRepository: gitHubRepository)
                self.navigationController?.pushViewController(detailViewController, animated: true)
            })
            .disposed(by: disposeBag)

        let event = Observable.combineLatest(viewModel.gitHubRepositories, viewModel.error)
            .asDriver(onErrorJustReturn: ([], nil))

        event
            .map { repositories, error in
                repositories.isEmpty || error != nil ? self.tableView.bounds.height : CGFloat.leastNormalMagnitude
            }
            .drive(tableView.rx.sectionHeaderHeight)
            .disposed(by: disposeBag)

        event
            .map { repositories, error -> UIView? in
                if error != nil {
                    return self.errorViewController.view
                } else if repositories.isEmpty {
                    return self.emptyViewController.view
                } else {
                    return nil
                }
            }
            .drive(tableView.rx.tableHeaderView)
            .disposed(by: disposeBag)

        tableView.addSubview(indicatorView, constraints: .center())
        tableView.register(RepositoryTableViewCell.self)

        title = "検索"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        errorViewController.setRefreshButtonHandler { [weak self] in
            if self?.viewModel.initialGitHubRepositories.value == nil {
                self?.viewModel.setInitialGitHubRepositories()
            } else {
                self?.viewModel.searchGitHubRepositories()
            }
        }

        viewModel.setInitialGitHubRepositories()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.indexPathsForSelectedRows?.forEach {
            tableView.deselectRow(at: $0, animated: true)
        }
    }
}
