//
//  UITableView+Toolkit.swift
//  Toolkit
//
//  Created by Andras Olah on 2026. 01. 07..
//

#if canImport(UIKit)
import UIKit

public extension UITableViewCell {
    static var reuseIdentifier: String {
        String(describing: self)
    }
}

public extension UITableView {
    func registerCell<T: UITableViewCell>(_ type: T.Type) {
        self.register(type, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        
        return cell
    }
}
#endif
