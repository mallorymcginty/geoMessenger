//
//  CustomButton.swift
//  geoMessenger
//
//  Created by Ivor D. Addo, PhD on 3/26/17.
//  Copyright © 2017 Mallory McGinty. All rights reserved.
//

import UIKit

@IBDesignable
class CustomButton: UIButton {
    @IBInspectable var borderColor: UIColor? = UIColor.clear {
        didSet {
            layer.borderColor = self.borderColor?.cgColor
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = self.borderWidth
        }
    }
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = self.cornerRadius
            layer.masksToBounds = self.cornerRadius > 0
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func draw(_ rect: CGRect) {
        self.layer.cornerRadius = self.cornerRadius
        self.layer.borderWidth = self.borderWidth
        self.layer.borderColor = self.borderColor?.cgColor
    }
}
