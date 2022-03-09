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

    private var errorViewRefreshButtonDidTap: PublishSubject<Void> = .init()

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

        // RxのサンプルではviewModelをviewDidLoadでinitし、initでbindしているが
        // それだと抽象化ができないのでinitとbindを分けている
        viewModel.bind(input: .init(searchText: searchController.searchBar.searchTextField.rx.text.orEmpty.asDriver(),
                                    searchButtonClicked: searchController.searchBar.rx.searchButtonClicked.asSignal(),
                                    cancelButtonClicked: searchController.searchBar.rx.cancelButtonClicked.asSignal(),
                                    itemSelected: tableView.rx.itemSelected.asSignal(),
                                    errorViewRefreshButtonDitTap: errorViewRefreshButtonDidTap.asSignal(onErrorSignalWith: .empty())))

        viewModel.searchText
            .asDriver()
            .drive(searchController.searchBar.searchTextField.rx.text)
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

        viewModel.headerViewType
            .map { [weak self] headerViewType -> UIView? in
                switch headerViewType {
                case .error: return self?.errorViewController.view
                case .empty: return self?.emptyViewController.view
                case .none: return nil
                }
            }
            .drive(tableView.rx.tableHeaderView)
            .disposed(by: disposeBag)

        // viewModelにheaderViewHeightとか作った方が良い？
        // 「ViewTypeがAの時は高さがaである」はロジックなのか否か
        // 1:1対応なので、これでもいいのかな？
        viewModel.headerViewType
            .map { headerViewType in
                switch headerViewType {
                case .error: return self.tableView.bounds.height
                case .empty: return self.tableView.bounds.height
                case .none: return CGFloat.leastNormalMagnitude
                }
            }
            .drive(tableView.rx.sectionHeaderHeight)
            .disposed(by: disposeBag)

        viewModel.showDetalView
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] gitHubRepository in
                guard let self = self else { return }
                let detailHeadingViewController = RepositoryDetailHeadingViewController.build(viewModel: RepositoryDetailHeadingViewModelImpl(gitHubRepository: gitHubRepository))

                let detailCountViewController = RepositoryDetailCountViewController.build(viewModel: RepositoryDetailCountViewModelImpl(gitHubRepository: gitHubRepository))

                let detailViewController = RepositoryDetailViewController.build(headingViewController: detailHeadingViewController,
                                                                                      countViewController: detailCountViewController,
                                                                                      gitHubRepository: gitHubRepository)
                self.navigationController?.pushViewController(detailViewController, animated: true)
            })
            .disposed(by: disposeBag)

        tableView.addSubview(indicatorView, constraints: .center())
        tableView.register(RepositoryTableViewCell.self)

        title = "検索"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        // errorViewControllerのButtonがviewDidLoadで取れないので、PublishSubjectを経由、いい方法ある？
        errorViewController.setRefreshButtonHandler { [weak self] in
            self?.errorViewRefreshButtonDidTap.onNext(())
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.indexPathsForSelectedRows?.forEach {
            tableView.deselectRow(at: $0, animated: true)
        }
    }
}
