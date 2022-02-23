//
//  Logger.swift
//
//  Created by kntk on 2021/10/24.
//

import SwiftyBeaver

public typealias Logger = SwiftyBeaver

public extension Logger {

    static func setup() {
        let destination = ConsoleDestination()
        SwiftyBeaver.addDestination(destination)
    }
}

