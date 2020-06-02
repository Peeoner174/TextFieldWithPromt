//
//  UnderlinedTextFieldWithPromt.swift
//  TextFieldWithPromt
//
//  Created by MSI on 02.06.2020.
//  Copyright © 2020 MSI. All rights reserved.
//

import Foundation
import UIKit

public class UnderlinedTextFieldWithPromt: TextFieldWithPromt {
    
    private(set) var customSeparator = UIView(frame: .zero)
    
    /// Colors
    @IBInspectable var customSeparatorOnFocusColor: UIColor = .black
    @IBInspectable var customSeparatorDefaultColor: UIColor = .black
    @IBInspectable var customSeparatorOnFailValidationColor: UIColor = .red
    
    private var defaultSeparatorframe: CGRect {
        return CGRect(x: 0,
                      y: frame.size.height - 0.5,
                      width: frame.size.width - 16,
                      height: 1)
    }

    private var boldSeparatorFrame: CGRect {
        var frameToApply = defaultSeparatorframe
        frameToApply.origin.y = frame.size.height - 1.5
        frameToApply.size.height = 2
        
        return frameToApply
    }
    
    private func adjustSeparatorOnInteraction() {
        customSeparator.frame = boldSeparatorFrame
    }
    
    private func adjustSeparatorOnEndEditing() {
        customSeparator.frame = defaultSeparatorframe
    }
    
    // MARK: - Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customSeparator.backgroundColor =  UIColor(red: 0.93, green: 0.94, blue: 0.96, alpha: 1)
        addSubview(customSeparator)
    }
    
    // MARK: - Update color
    
    override func setFocusColorStyle() {
        super.setFocusColorStyle()
        customSeparator.backgroundColor = customSeparatorOnFocusColor
    }
    
    override func setDefaultColorStyle() {
        super.setDefaultColorStyle()
        customSeparator.backgroundColor = customSeparatorDefaultColor
    }
    
    override func setFailValidationColorStyle() {
        super.setFailValidationColorStyle()
        customSeparator.backgroundColor = customSeparatorOnFailValidationColor
    }
}

// MARK: - On user interactions events

extension UnderlinedTextFieldWithPromt {
    
    public override func textFieldDidBeginEditing(_ textField: UITextField) {
        super.textFieldDidBeginEditing(textField)
        adjustSeparatorOnInteraction()
    }
    
    public override func textFieldDidEndEditing(_ textField: UITextField) {
        super.textFieldDidEndEditing(textField)
        adjustSeparatorOnEndEditing()
    }
}
