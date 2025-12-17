//
//  UIView+Toolkit.swift
//  Toolkit
//
//  Created by Andras Olah on 2025. 12. 08..
//

#if canImport(UIKit)
import UIKit

extension UIView {
    public func anchorToSuperView(top: Bool = true, bottom: Bool = true, leading: Bool = true, trailing: Bool = true) {
        guard let superview else { return }
        
        self.topAnchor.constraint(equalTo: superview.topAnchor).isActive = top
        self.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = bottom
        self.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = leading
        self.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = trailing
    }
}

extension UIView {
    public static func emptyView(height: CGFloat? = nil) -> UIView {
        let spacerView = UIView()
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        
        if let height {
            NSLayoutConstraint.activate([
                spacerView.heightAnchor.constraint(equalToConstant: height)
            ])
        } else {
            spacerView.setContentHuggingPriority(.defaultLow, for: .vertical)
        }
        
        return spacerView
    }
}
#endif
