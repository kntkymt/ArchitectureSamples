//
//  RepositorySearchViewModel.swift
//  MVVM_RX
//
//  Created by kntk on 2022/02/24.
//

import Foundation
import ReactiveCocoa
import ReactiveSwift

import AppError
import Loging
import Model

enum HeaderViewType {
    case error
    case empty
}

struct RepositorySearchViewModelInput {

    var searchText: Signal<String, Never>
    var searchButtonClicked: Signal<Void, Never>
    var cancelButtonClicked: Signal<Void, Never>
    var itemSelected: Signal<IndexPath, Never>
    var errorViewRefreshButtonDitTap: Signal<Void, Never>
}

protocol RepositorySearchViewModel {

    func bind(input: RepositorySearchViewModelInput)

    var isLoading: MutableProperty<Bool> { get }
    var searchText: MutableProperty<String> { get }
    var initialGitHubRepositories: MutableProperty<[GitHubRepository]?> { get }
    var gitHubRepositories: MutableProperty<[GitHubRepository]> { get }
    var error: MutableProperty<(title: String, message: String)?> { get }

    var headerViewType: Signal<HeaderViewType?, Never> { get }
    var showDetalView: Signal<GitHubRepository, Never> { get }
}

final class RepositorySearchViewModelImpl: RepositorySearchViewModel {

    // MARK: - Property

    private let gitHubRepositorySearchUsecase: GitHubRepositorySearchUsecase

    var searchText: MutableProperty<String> = .init("")

    var isLoading: MutableProperty<Bool> = .init(false)
    var initialGitHubRepositories: MutableProperty<[GitHubRepository]?> = .init(nil)
    var gitHubRepositories: MutableProperty<[GitHubRepository]> = .init([])
    var error: MutableProperty<(title: String, message: String)?> = .init(nil)

    var headerViewType: Signal<HeaderViewType?, Never> = .empty
    var showDetalView: Signal<GitHubRepository, Never> = .empty

    private var disposeBag = CompositeDisposable()

    // MARK: - Initializer

    init(gitHubRepositorySearchUsecase: GitHubRepositorySearchUsecase) {
        self.gitHubRepositorySearchUsecase = gitHubRepositorySearchUsecase
    }

    func bind(input: RepositorySearchViewModelInput) {
        headerViewType = Signal.combineLatest(gitHubRepositories.signal, error.signal)
            .map { repositories, error -> HeaderViewType? in
                if error != nil {
                    return .error
                } else if repositories.isEmpty {
                    return .empty
                } else {
                    return nil
                }
            }

        showDetalView = input.itemSelected
            .withLatest(from: gitHubRepositories.signal)
            .map { (indexPath, gitHubRepositories) in
                gitHubRepositories[indexPath.row]
            }

        disposeBag.add(searchText <~ input.searchText)

        disposeBag.add(input.searchButtonClicked.observeValues { [weak self] in
            self?.searchGitHubRepositories()
        })

        disposeBag.add(input.cancelButtonClicked.observeValues { [weak self] in
            self?.setInitialGitHubRepositories()
        })

        disposeBag.add(input.errorViewRefreshButtonDitTap.withLatest(from: initialGitHubRepositories.signal)
            .observeValues { [weak self] (_, initialGitHubRepositories) in
                if initialGitHubRepositories == nil {
                    self?.setInitialGitHubRepositories()
                } else {
                    self?.searchGitHubRepositories()
                }
            })

        setInitialGitHubRepositories()
    }

    // MARK: - Public

    func searchGitHubRepositories() {
        isLoading.value = true

        disposeBag.add(gitHubRepositorySearchUsecase.searchGitHubRepositories(by: searchText.value)
                        .startWithResult { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let repositories):
                self.error.value = nil
                self.gitHubRepositories.value = repositories
                self.isLoading.value = false

            case .failure(let error):
                self.gitHubRepositories.value = []

                Logger.error(error)
                self.handle(error)
                self.isLoading.value = false
            }
        })
    }

    func setInitialGitHubRepositories() {
        if let initialGitHubRepositories = initialGitHubRepositories.value {
            gitHubRepositories.value = initialGitHubRepositories
            error.value = nil

        } else {
            isLoading.value = true

            disposeBag.add(gitHubRepositorySearchUsecase.getTrendingGitHubRepositories()
                            .startWithResult { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let repositories):
                    self.error.value = nil
                    self.initialGitHubRepositories.value = repositories
                    self.gitHubRepositories.value = repositories
                    self.isLoading.value = false

                case .failure(let error):
                    Logger.error(error)
                    self.handle(error)
                    self.isLoading.value = false

                }
            })
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

        self.error.value = (title: title, message: message)
    }
}
