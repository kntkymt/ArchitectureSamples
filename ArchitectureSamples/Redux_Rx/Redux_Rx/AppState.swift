//
//  AppState.swift
//  Redux_Rx
//
//  Created by kntk on 2022/03/30.
//

import Foundation
import ReSwift

struct AppState {
    var repositorySearchState: RepositorySearchState
    var repositoryDetailState: RepositoryDetailState?
}

func appReducer(action: Action, state: AppState?) -> AppState {
    var state = state ?? AppState(repositorySearchState: .init())

    if let action = action as? InitAction {
        return initializeReducer(action: action, state: state)
    }

    state.repositorySearchState = RepositorySearchState.reducer(action: action, state: state.repositorySearchState)

    if let repositoryDetailState = state.repositoryDetailState {
        state.repositoryDetailState = RepositoryDetailState.reducer(action: action, state: repositoryDetailState)
    }

    if let repositoryDetailState = state.repositoryDetailState {
        state.repositoryDetailState = RepositoryDetailState.reducer(action: action, state: repositoryDetailState)
    }

    return state
}
