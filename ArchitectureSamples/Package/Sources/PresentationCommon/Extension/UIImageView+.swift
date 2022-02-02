//
//  UIImageView+.swift
//
//  Created by kntk on 2021/10/24.
//

import Foundation
import UIKit
import Nuke

public extension UIImageView {

    func load(_ url: URL?, placeholder: UIImage? = nil, contentMode: UIImageView.ContentMode = .scaleAspectFit) {
        guard let url = url else { return }

        let contentModes = ImageLoadingOptions.ContentModes(success: contentMode, failure: contentMode, placeholder: contentMode)
        let options: ImageLoadingOptions = {
            if let placeholder = placeholder {
                return ImageLoadingOptions(placeholder: placeholder, contentModes: contentModes)
            } else {
                return ImageLoadingOptions(contentModes: contentModes)
            }
        }()
        
        Nuke.loadImage(with: url, options: options, into: self)
    }
}
