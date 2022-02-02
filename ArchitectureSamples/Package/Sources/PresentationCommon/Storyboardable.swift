//
//  Storyboardable.swift
//
//  Created by kntk on 2021/10/23.
//

import UIKit

public protocol Storyboardable {

    associatedtype Instance

    static var bundle: Bundle? { get }
    static var storyboardName: String { get }
    static var storyboard: UIStoryboard { get }
    static func initViewController() -> Instance
}

public extension Storyboardable where Self: UIViewController {

    static var bundle: Bundle? {
        return Bundle.module
    }

    static var storyboardName: String {
        return String(describing: self)
    }

    static var storyboard: UIStoryboard {
        return UIStoryboard(name: storyboardName, bundle: bundle)
    }

    static func initViewController() -> Self {
        return storyboard.instantiateInitialViewController() as! Self
    }
}
