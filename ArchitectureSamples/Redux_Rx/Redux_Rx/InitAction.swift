//
//  InitAction.swift
//  Redux_Rx
//
//  Created by kntk on 2022/03/30.
//

import Foundation
import ReSwift

import Model

enum InitAction: Action {
    case repositoryDetail(gitHubRepository: GitHubRepository)
}

func initializeReducer(action: InitAction, state: AppState) -> AppState {
    var state = state
    switch action {
    case .repositoryDetail(let gitHubRepository):
        state.repositoryDetailState = .init(repository: gitHubRepository)
    }
    
    return state
}
