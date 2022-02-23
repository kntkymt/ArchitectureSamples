//
//  GitHubRepositoryDetailProtocol.swift
//
//  Created by kntk on 2021/10/24.
//

import Foundation

import Model

protocol RepositoryDetailHeadingView: AnyObject {

    /// GitHubのリポジトリ詳細を表示する
    ///
    /// - parameters:
    ///     - gitHubRepository: GitHubのリポジトリ
    func showGitHubRepositoryDetailHeading(gitHubRepository: GitHubRepository)
}

protocol RepositoryDetailHeadingPresentation: Presentation {
}
