//
//  ErrorViewController.swift
//
//  Created by kntk on 2021/10/27.
//

import UIKit

public final class ErrorViewController: UIViewController, Storyboardable {

    // MARK: - Outlet

    @IBOutlet private weak var refreshButton: UIButton!
    @IBOutlet private weak var refreshLabel: UILabel! {
        didSet {
            refreshLabel.text = refreshTitle
        }
    }

    // MARK: - Property

    private var refreshTitle: String!
    private var hideRefreshButton: Bool!

    private var refreshButtonHandler: (() -> Void)?

    // MARK: - Static

    public static func build(refreshTitle: String, hideRefreshButton: Bool) -> Self {
        let viewController = initViewController()
        viewController.refreshTitle = refreshTitle
        viewController.hideRefreshButton = hideRefreshButton

        return viewController
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshButton.isHidden = hideRefreshButton
    }

    // MARK: - Public

    public func setRefreshButtonHandler(handler: @escaping () -> Void) {
        self.refreshButtonHandler = handler
    }

    // MARK: - Action

    @IBAction private func refreshButtonDidTap(_ sender: Any) {
        refreshButtonHandler?()
    }
}

