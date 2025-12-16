//
//  UIStackView+Extensions.swift
//  Toolkit
//
//  Created by Andras Olah on 2025. 12. 17..
//

import UIKit

extension UIStackView {
    public func removeAllArrangedSubviews() {
        for view in arrangedSubviews {
            removeArrangedSubview(view)
        }
    }
}
