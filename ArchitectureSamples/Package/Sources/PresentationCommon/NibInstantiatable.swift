//
//  NibInstantiatable.swift
//
//  Created by kntk on 2021/10/25.
//

import UIKit

public protocol NibInstantiatable {

    associatedtype Dependency

    func inject(_ dependency: Dependency)

    static var bundle: Bundle? { get }
    static var identifier: String { get }
    static var nibName: String { get }
    static var nib: UINib { get }
}

public extension NibInstantiatable {

    static var bundle: Bundle? {
        return Bundle.module
    }

    static var nibName: String {
        return String(describing: self)
    }

    static var identifier: String {
        return nibName
    }

    static var nib: UINib {
        return UINib(nibName: nibName, bundle: bundle)
    }
}
