//
//  RepositoryDetailStore.swift
//  Flux_Rx
//
//  Created by kntk on 2022/03/23.
//

import Foundation
import RxRelay
import RxCocoa
import RxSwift

import Model

final class RepositoryDetailStore {

    // MARK: - Property

    let gitHubRepository: BehaviorRelay<GitHubRepository>

    private var disposeBag = DisposeBag()

    // MARK: - Initializer

    init(gitHubRepository: GitHubRepository, dispatcher: RepositoryDetailDispatcher) {
        self.gitHubRepository = .init(value: gitHubRepository)
    }
}
