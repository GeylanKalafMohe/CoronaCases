//
//  UIView+Ext.swift
//  CoronaCases
//
//  Created by SwiftiSwift on 19.03.20.
//  Copyright © 2020 SwiftiSwift. All rights reserved.
//

import UIKit

extension UIView {
    func pinEdges(to other: UIView, withEqualPadding padding: CGFloat = 0) {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: other.leadingAnchor, constant: padding),
            trailingAnchor.constraint(equalTo: other.trailingAnchor, constant: -padding),
            topAnchor.constraint(equalTo: other.topAnchor, constant: padding),
            bottomAnchor.constraint(equalTo: other.bottomAnchor, constant: -padding)
        ])
    }
}
