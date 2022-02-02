//
//  File.swift
//  
//
//  Created by kntk on 2022/02/03.
//

import UIKit

public extension UITableView {

    func scrollToTop(animated: Bool) {
        if self.numberOfRows(inSection: 0) != 0 {
            self.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: animated)
        }
    }
}
