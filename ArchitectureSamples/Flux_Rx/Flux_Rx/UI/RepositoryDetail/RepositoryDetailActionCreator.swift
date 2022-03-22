//
//  RepositoryDetailActionCreator.swift
//  Flux_Rx
//
//  Created by kntk on 2022/03/23.
//

import Foundation
import RxSwift

import Model
import Loging

final class RepositoryDetailActionCreator {

    // MARK: - Property

    private let dispatcher: RepositoryDetailDispatcher

    private var disposeBag = DisposeBag()

    // MARK: - Initializer

    init(dispatcher: RepositoryDetailDispatcher) {
        self.dispatcher = dispatcher
    }
}
