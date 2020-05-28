//
//  CustomUIView.swift
//  CoronaCases
//
//  Created by SwiftiSwift on 27.03.20.
//  Copyright © 2020 SwiftiSwift. All rights reserved.
//

import UIKit

@IBDesignable
class CustomUIView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = .black {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
}
