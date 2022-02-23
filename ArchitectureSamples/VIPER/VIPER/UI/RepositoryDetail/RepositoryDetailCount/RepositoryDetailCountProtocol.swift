//
//  GitHubRepositoryDetailCountProtocol.swift
//
//  Created by kntk on 2021/10/25.
//

import Model

protocol RepositoryDetailCountView: AnyObject {

    /// GitHubのリポジトリ詳細を表示する
    ///
    /// - parameters:
    ///     - gitHubRepository: GitHubのリポジトリ
    func showGitHubRepositoryDetailCount(gitHubRepository: GitHubRepository)
}

protocol RepositoryDetailCountPresentation: Presentation {
}

protocol RepositoryDetailCountWireframe: AnyObject {
    
}
