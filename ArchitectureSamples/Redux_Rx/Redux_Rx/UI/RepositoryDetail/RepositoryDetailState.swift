//
//  RepositoryDetailState.swift
//  Redux_Rx
//
//  Created by kntk on 2022/03/30.
//

import Foundation
import ReSwift

import Model

struct RepositoryDetailState {
    private(set) var repository: GitHubRepository
}

// MARK: - Action

extension RepositoryDetailState {

    enum Action {

    }
}

// MARK: - Reducer

extension RepositoryDetailState {
    static func reducer(action: ReSwift.Action, state: Self) -> Self {
        return state
    }
}
