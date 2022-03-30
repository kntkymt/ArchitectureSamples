//
//  RxStore.swift
//  Redux_Rx
//
//  Created by kntk on 2022/03/30.
//

import Foundation

import RxSwift
import ReSwift
import RxCocoa

final class RxStore: StoreSubscriber, DispatchingStoreType {

    // MARK: - Property

    // subscribeする用
    public lazy var stateObservable: RxSwift.Observable<AppState> = {
        return self.stateBehaviorRelay
            .observe(on: MainScheduler.instance)
            .share(replay: 1)
    }()
    private lazy var stateBehaviorRelay: RxCocoa.BehaviorRelay<AppState> = {
        return .init(value: self.state)
    }()

    var state: AppState {
        return store.state
    }

    private var store: Store<AppState>

    // MARK: - Initializer

    init(store: Store<AppState>) {
        self.store = store
        self.store.subscribe(self)
    }

    // MARK: - Lifecycle

    func newState(state: AppState) {
        stateBehaviorRelay.accept(state)
    }

    func dispatch(_ action: Action) {
        if Thread.isMainThread {
            store.dispatch(action)
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.store.dispatch(action)
            }
        }
    }

    deinit {
        store.unsubscribe(self)
    }

    // MARK: - Public

    func dispatch(_ actionCreator: RepositorySearchState.Action.RequestActionCreator) {
        // FIXME: dispatch(action: )を呼ぶようにする
        actionCreator(self.state, self)
    }
}

