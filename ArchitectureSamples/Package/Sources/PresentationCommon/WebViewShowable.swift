//
//  WebViewShowable.swift
//
//  Created by kntk on 2021/10/26.
//

import SafariServices

protocol WebViewShowable {

    /// SafariアプリでURLを開く
    ///
    /// - parameters:
    ///     - url: 開くURL
    func openSafariApp(url: URL)

    /// SafariViewControllerでURLを開く
    ///
    /// - parameters:
    ///     - url: 開くURL
    func presentSafariViewController(url: URL)
}

extension WebViewShowable where Self: UIViewController {

    func openSafariApp(url: URL) {
        guard UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }

    func presentSafariViewController(url: URL) {
        guard UIApplication.shared.canOpenURL(url) else { return }
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true)
    }
}
