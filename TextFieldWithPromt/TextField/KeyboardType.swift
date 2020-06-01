//
//  KeyboardType.swift
//  TextFieldWithPromt
//
//  Created by MSI on 02.06.2020.
//  Copyright © 2020 MSI. All rights reserved.
//

import UIKit

public enum KeyboardType : Int {
    
    case `default` // Default type for the current input method.
    
    case asciiCapable // Displays a keyboard which can enter ASCII characters
    
    case numbersAndPunctuation // Numbers and assorted punctuation.
    
    case URL // A type optimized for URL entry (shows . / .com prominently).
    
    case numberPad // A number pad with locale-appropriate digits (0-9, ۰-۹, ०-९, etc.). Suitable for PIN entry.
    
    case phonePad // A phone pad (1-9, *, 0, #, with letters under the numbers).
    
    case namePhonePad // A type optimized for entering a person's name or phone number.
    
    case emailAddress // A type optimized for multiple email address entry (shows space @ . prominently).
    
    @available(iOS 4.1, *)
    case decimalPad // A number pad with a decimal point.
    
    @available(iOS 5.0, *)
    case twitter // A type optimized for twitter text entry (easy access to @ #)
    
    @available(iOS 7.0, *)
    case webSearch // A default keyboard type with URL-oriented addition (shows space . prominently).
    
    @available(iOS 10.0, *)
    case asciiCapableNumberPad // A number pad (0-9) that will always be ASCII digits.
    
    case datePicker // date picker pad
    
    case picker // picker view
    
    func asUIKeyboardType() -> UIKeyboardType? {
        switch self {
        case .default:
            return .default
        case .asciiCapable:
            return .asciiCapable
        case .asciiCapableNumberPad:
            return .asciiCapableNumberPad
        case .datePicker, .picker:
            return nil
        case .decimalPad:
            return .decimalPad
        case .emailAddress:
            return .emailAddress
        case .namePhonePad:
            return .namePhonePad
        case .numberPad:
            return .numberPad
        case .numbersAndPunctuation:
            return .numbersAndPunctuation
        case .URL:
            return .URL
        case .phonePad:
            return .phonePad
        case .twitter:
            return .twitter
        case .webSearch:
            return .webSearch
        }
    }
}
