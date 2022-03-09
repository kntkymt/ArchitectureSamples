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

    var isLoading: BehaviorRelay<Bool> { get }
    var searchText: BehaviorRelay<String> { get }
    var initialGitHubRepositories: BehaviorRelay<[GitHubRepository]?> { get }
    var gitHubRepositories: BehaviorRelay<[GitHubRepository]> { get }
    var error: BehaviorRelay<(title: String, message: String)?> { get }

    var headerViewType: Driver<HeaderViewType?> { get }
    var showDetalView: Signal<GitHubRepository> { get }
}

final class RepositorySearchViewModelImpl: RepositorySearchViewModel {

    // MARK: - Property

    private let gitHubRepositorySearchUsecase: GitHubRepositorySearchUsecase

    var searchText: BehaviorRelay<String> = .init(value: "")

    var isLoading: BehaviorRelay<Bool> = .init(value: false)
    var initialGitHubRepositories: BehaviorRelay<[GitHubRepository]?> = .init(value: nil)
    var gitHubRepositories: BehaviorRelay<[GitHubRepository]> = .init(value: [])
    var error: BehaviorRelay<(title: String, message: String)?> = .init(value: nil)

    var headerViewType: Driver<HeaderViewType?> = .empty()
    var showDetalView: Signal<GitHubRepository> = .empty()

    private var disposeBag = DisposeBag()

    // MARK: - Initializer

    init(gitHubRepositorySearchUsecase: GitHubRepositorySearchUsecase) {
        self.gitHubRepositorySearchUsecase = gitHubRepositorySearchUsecase
    }

    func bind(input: RepositorySearchViewModelInput) {
        headerViewType = Driver.combineLatest(gitHubRepositories.asDriver(), error.asDriver())
            .map { repositories, error -> HeaderViewType? in
                if error != nil {
                    return .error
                } else if repositories.isEmpty {
                    return .empty
                } else {
                    return nil
                }
            }

        let indexPathAndGitHubRepositories = Driver.combineLatest(input.itemSelected.asDriver(onErrorDriveWith: .empty()), gitHubRepositories.asDriver()) {
            (indexPath: $0, gitHubRepositories: $1)
        }

        // a.hoge(b) Observable<A> -> Observable<(A, B)>みたいなオペレーターが欲しいけどない？
        showDetalView = input.itemSelected
            .withLatestFrom(indexPathAndGitHubRepositories)
            .map { (indexPath, gitHubRepositories) in
                gitHubRepositories[indexPath.row]
            }
            .asSignal()

        input.searchText
            .drive(searchText)
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
            .withLatestFrom(initialGitHubRepositories.asDriver())
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

    // MARK: - Public

    func searchGitHubRepositories() {
        isLoading.accept(true)

        gitHubRepositorySearchUsecase.searchGitHubRepositories(by: searchText.value)
            .subscribe(onSuccess: { repositories in
                self.error.accept(nil)
                self.gitHubRepositories.accept(repositories)

                self.isLoading.accept(false)
            }, onFailure: { error in
                self.gitHubRepositories.accept([])

                Logger.error(error)
                self.handle(error)

                self.isLoading.accept(false)
            })
            .disposed(by: disposeBag)
    }

    func setInitialGitHubRepositories() {
        if let initialGitHubRepositories = initialGitHubRepositories.value {
            gitHubRepositories.accept(initialGitHubRepositories)
            error.accept(nil)

        } else {
            isLoading.accept(true)
            gitHubRepositorySearchUsecase.getTrendingGitHubRepositories()
                .subscribe(onSuccess: { repositories in
                    self.error.accept(nil)
                    self.initialGitHubRepositories.accept(repositories)
                    self.gitHubRepositories.accept(repositories)

                    self.isLoading.accept(false)
                }, onFailure: { error in
                    Logger.error(error)
                    self.handle(error)

                    self.isLoading.accept(false)
                })
                .disposed(by: disposeBag)
        }
    }

    // MARK: - Private

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

        self.error.accept((title: title, message: message))
    }
}
