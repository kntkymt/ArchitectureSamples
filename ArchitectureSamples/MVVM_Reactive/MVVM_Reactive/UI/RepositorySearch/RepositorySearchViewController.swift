//
//  RepositorySearchViewController.swift
//  Fat
//
//  Created by kntk on 2022/02/03.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift

import AppError
import Loging
import PresentationCommon
import Model

final class RepositorySearchViewController: UIViewController, Storyboardable, BannerShowable {

    // MARK: - Outlet

    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }

    // MARK: - Property

    private var disposeBag = CompositeDisposable()

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

    private var itemSelectedInput: Signal<IndexPath, Never>.Observer!
    private var errorViewRefreshButtonDidTapInput: Signal<Void, Never>.Observer!

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

        let (itemSelectedOutput, itemSelectedInput) = Signal<IndexPath, Never>.pipe(disposable: disposeBag)
        self.itemSelectedInput = itemSelectedInput

        let (errorViewRefreshButtonDidTapOutput, errorViewRefreshButtonDidTapInput) = Signal<Void, Never>.pipe(disposable: disposeBag)
        self.errorViewRefreshButtonDidTapInput = errorViewRefreshButtonDidTapInput

        viewModel.bind(input: .init(searchText: searchController.searchBar.searchTextField.reactive.continuousTextValues,
                                    searchButtonClicked: searchController.searchBar.reactive.searchButtonClicked,
                                    cancelButtonClicked: searchController.searchBar.reactive.cancelButtonClicked,
                                    itemSelected: itemSelectedOutput,
                                    errorViewRefreshButtonDitTap: errorViewRefreshButtonDidTapOutput))

        disposeBag.add(searchController.searchBar.searchTextField.reactive.text <~ viewModel.searchText.signal)
        disposeBag.add(indicatorView.reactive.isAnimating <~ viewModel.isLoading.signal)
        disposeBag.add(tableView.reactive.isUserInteractionEnabled <~ viewModel.isLoading.signal.map { !$0 })
        disposeBag.add(viewModel.error
                        .signal
                        .skipNil()
                        .observeValues { [weak self] title, message in
                            self?.showErrorBanner(title, with: message)
        })
        disposeBag.add(viewModel.gitHubRepositories
                        .signal
                        .observeValues { [weak self] _ in

            self?.tableView.reloadData()
        })

        disposeBag.add(viewModel.headerViewType
                        .map { [weak self] headerViewType -> UIView? in
                            switch headerViewType {
                            case .error: return self?.errorViewController.view
                            case .empty: return self?.emptyViewController.view
                            case .none: return nil
                            }
                        }
                        .observeValues { [weak self] headerView in
                            self?.tableView?.tableHeaderView = headerView
                        }
        )

        // viewModelにheaderViewHeightとか作った方が良い？
        // 「ViewTypeがAの時は高さがaである」はロジックなのか否か
        // 1:1対応なので、これでもいいのかな？
        disposeBag.add(viewModel.headerViewType
            .map { headerViewType in
                switch headerViewType {
                case .error: return self.tableView.bounds.height
                case .empty: return self.tableView.bounds.height
                case .none: return CGFloat.leastNormalMagnitude
                }
            }
            .observeValues { [weak self] height in
                self?.tableView?.sectionHeaderHeight = height
            }
        )

        disposeBag.add(viewModel.showDetalView
                        .signal
                        .observeValues { [weak self] gitHubRepository in
                            guard let self = self else { return }
                            let detailHeadingViewController = RepositoryDetailHeadingViewController.build(viewModel: RepositoryDetailHeadingViewModelImpl(gitHubRepository: gitHubRepository))

                            let detailCountViewController = RepositoryDetailCountViewController.build(viewModel: RepositoryDetailCountViewModelImpl(gitHubRepository: gitHubRepository))

                            let detailViewController = RepositoryDetailViewController.build(headingViewController: detailHeadingViewController,
                                                                                                  countViewController: detailCountViewController,
                                                                                                  gitHubRepository: gitHubRepository)
                            self.navigationController?.pushViewController(detailViewController, animated: true)
                        })

        tableView.addSubview(indicatorView, constraints: .center())
        tableView.register(RepositoryTableViewCell.self)

        title = "検索"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        // errorViewControllerのButtonがviewDidLoadで取れないので、PublishSubjectを経由、いい方法ある？
        errorViewController.setRefreshButtonHandler { [weak self] in
            self?.errorViewRefreshButtonDidTapInput.send(value: ())
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.indexPathsForSelectedRows?.forEach {
            tableView.deselectRow(at: $0, animated: true)
        }
    }
}

extension RepositorySearchViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.gitHubRepositories.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let repository = viewModel.gitHubRepositories.value[indexPath.row]
        return tableView.dequeue(RepositoryTableViewCell.self, for: indexPath, with: repository)
    }
}

extension RepositorySearchViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemSelectedInput.send(value: indexPath)
    }
}
