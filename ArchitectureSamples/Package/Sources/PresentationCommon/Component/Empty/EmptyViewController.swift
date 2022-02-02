//
//  EmptyViewController.swift
//
//  Created by kntk on 2021/10/26.
//

import UIKit

public final class EmptyViewController: UIViewController, Storyboardable {

    // MARK: - Outlet

    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            self.titleLabel.text = emptyTitle
        }
    }

    // MARK: - Property

    private var emptyTitle: String!

    // MARK: - Build

    public static func build(emptyTitle: String) -> Self {
        let viewControlelr = initViewController()
        viewControlelr.emptyTitle = emptyTitle
        return viewControlelr
    }
}
