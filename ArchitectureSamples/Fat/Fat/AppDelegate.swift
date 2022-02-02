//
//  AppDelegate.swift
//  Fat
//
//  Created by kntk on 2022/02/03.
//

import UIKit

import Loging
import AppContainer
import Network
import Usecase
import Repository
import PresentationCommon

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Logger.setup()
        AppContainer.setup(gitHubRepositorySearchUsecase: GitHubRepositorySearchUsecaseImpl(gitHubRepositoryRepository: GitHubRepositoryRepositoryImpl()))
        API.setup(provider: APIProviderFactory.createService())

        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

extension Storyboardable where Self: UIViewController {

    static var bundle: Bundle? {
        return nil
    }
}

extension NibInstantiatable {
    static var bundle: Bundle? {
        return nil
    }
}
