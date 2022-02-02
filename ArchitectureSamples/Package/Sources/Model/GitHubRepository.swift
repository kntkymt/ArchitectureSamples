//
//  Repository.swift
//
//  Created by kntk on 2021/10/24.
//

import Foundation

public struct GitHubRepository: Codable {

    public var fullName: String
    public var name: String
    public var htmlUrl: URL
    public var language: String?
    public var description: String?
    public var owner: User
    public var stargazersCount: Int
    public var watchersCount: Int
    public var forksCount: Int
    public var openIssuesCount: Int

}
