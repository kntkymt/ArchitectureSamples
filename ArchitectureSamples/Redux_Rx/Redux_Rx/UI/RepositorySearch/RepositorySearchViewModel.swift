//
//  RepositorySearchViewModel.swift
//  MVVM_RX
//
//  Created by kntk on 2022/02/24.
//

import Foundation
import RxSwift
import RxRelay

import AppError
import Loging
import Model
import RxCocoa
import ReSwift

enum HeaderViewType {
    case error
    case empty
}

struct RepositorySearchViewModelInput {

    var searchText: Driver<String>
    var searchButtonClicked: Signal<Void>
    var cancelButtonClicked: Signal<Void>
    var itemSelected: Signal<IndexPath>
    var errorViewRefreshButtonDitTap: Signal<Void>
}

protocol RepositorySearchViewModel {

    func bind(input: RepositorySearchViewModelInput)

    var isLoading: Driver<Bool> { get }
    var searchText: Driver<String> { get }
    var gitHubRepositories: Driver<[GitHubRepository]> { get }
    var error: Driver<(title: String, message: String)?> { get }

    var headerViewType: Driver<HeaderViewType?> { get }
    var showDetalView: Signal<GitHubRepository> { get }
}

// ViewController側から見たInput, OutputはMVVMと同様
// Input, Outputの利用・提供方法がFluxは違う
// InputはActionCreatorへの要求に
// OutputはStoreから""必要な物だけ""を取り出して提供
final class RepositorySearchViewModelImpl: RepositorySearchViewModel {

    // MARK: - Property

    private let store: RxStore
    private let state: Observable<RepositorySearchState>

    private let gitHubRepositorySearchUsecase: GitHubRepositorySearchUsecase

    private var disposeBag = DisposeBag()

    let isLoading: Driver<Bool>
    let searchText: Driver<String>
    let gitHubRepositories: Driver<[GitHubRepository]>
    var error: Driver<(title: String, message: String)?> = .empty()

    var headerViewType: Driver<HeaderViewType?> = .empty()
    var showDetalView: Signal<GitHubRepository> = .empty()

    // MARK: - Initializer

    init(store: RxStore, state: Observable<RepositorySearchState>, gitHubRepositorySearchUsecase: GitHubRepositorySearchUsecase) {
        self.store = store
        self.state = state
        self.gitHubRepositorySearchUsecase = gitHubRepositorySearchUsecase

        self.isLoading = state.map { $0.isLoading }.asDriver(onErrorDriveWith: .empty())
        self.searchText = state.map { $0.searchText }.asDriver(onErrorDriveWith: .empty())
        self.gitHubRepositories = state.map { $0.gitHubRepositories }.asDriver(onErrorDriveWith: .empty())
        self.error = state.map { $0.error }
            .map { [weak self] error -> (title: String, message: String)? in
                if let error = error {
                    return self?.handle(error)
                } else {
                    return nil
                }
            }
            .asDriver(onErrorDriveWith: .empty())
    }

    func bind(input: RepositorySearchViewModelInput) {
        // 画面固有のプレゼンテーションロジックに関係する物はViewModelで普通に持つ
        headerViewType = Driver.combineLatest(state.map { $0.gitHubRepositories }.asDriver(onErrorDriveWith: .empty()), state.map { $0.error }.asDriver(onErrorDriveWith: .empty()))
            .map { repositories, error -> HeaderViewType? in
                if error != nil {
                    return .error
                } else if repositories.isEmpty {
                    return .empty
                } else {
                    return nil
                }
            }

        let indexPathAndGitHubRepositories = Driver.combineLatest(input.itemSelected.asDriver(onErrorDriveWith: .empty()), state.map { $0.gitHubRepositories }.asDriver(onErrorDriveWith: .empty())) {
            (indexPath: $0, gitHubRepositories: $1)
        }

        // a.hoge(b) Observable<A> -> Observable<(A, B)>みたいなオペレーターが欲しいけどない？
        showDetalView = input.itemSelected
            .withLatestFrom(indexPathAndGitHubRepositories)
            .map { [weak self] (indexPath, gitHubRepositories) in
                self?.store.dispatch(InitAction.repositoryDetail(gitHubRepository: gitHubRepositories[indexPath.row]))
                return gitHubRepositories[indexPath.row]
            }
            .asSignal()

        input.searchText
            .drive(onNext: { [weak self] searchText in
                self?.store.dispatch(RepositorySearchState.Action.setSearchText(searchText))
            })
            .disposed(by: disposeBag)

        input.searchButtonClicked
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.searchGitHubRepositories()
            })
            .disposed(by: disposeBag)

        input.cancelButtonClicked
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.setInitialGitHubRepositories()
            })
            .disposed(by: disposeBag)

        input.errorViewRefreshButtonDitTap
            .asDriver(onErrorDriveWith: .empty())
            .withLatestFrom(state.map { $0.initialGitHubRepositories }.asDriver(onErrorDriveWith: .empty()))
            .drive(onNext: { [weak self] initialGitHubRepositories in
                if initialGitHubRepositories == nil {
                    self?.setInitialGitHubRepositories()
                } else {
                    self?.searchGitHubRepositories()
                }
            })
            .disposed(by: disposeBag)

        setInitialGitHubRepositories()
    }

    // MARK: - Private

    private func searchGitHubRepositories() {
        store.dispatch(RepositorySearchState.Action.searchGitHubRepositoriesAsyncCreator(by: store.state.repositorySearchState.searchText, usecase: gitHubRepositorySearchUsecase, disposeBag: disposeBag))
    }

    private func setInitialGitHubRepositories() {
        if let initialGitHubRepositories = store.state.repositorySearchState.initialGitHubRepositories {
            store.dispatch(RepositorySearchState.Action.setGitHubRepositories(initialGitHubRepositories))
            store.dispatch(RepositorySearchState.Action.setError(nil))
        } else {
            store.dispatch(RepositorySearchState.Action.fetchInitialGitHubRepositories(usecase: gitHubRepositorySearchUsecase, disposeBag: disposeBag))
        }
    }

    private func handle(_ error: Error) -> (title: String, message: String) {

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

        return (title: title, message: message)
    }
}
