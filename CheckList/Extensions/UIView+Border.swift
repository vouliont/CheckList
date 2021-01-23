//
//  UIView+Border.swift
//  CheckList
//
//  Created by Владислав on 22.01.2021.
//

import UIKit

extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        set {
            self.layer.cornerRadius = newValue
        }
        get {
            return self.layer.cornerRadius
        }
    }
}

