//
//  MaskText.swift
//  TextFieldWithPromt
//
//  Created by MSI on 02.06.2020.
//  Copyright © 2020 MSI. All rights reserved.
//

import Foundation

// MARK: - Templates

let phoneMask = "+N (NNN) NNN-NN-NN"
let emptyMask = ""

// MARK: - Static funcs

extension MaskText {
    
    static func getMaskedText(inputText: String?, mask: String) -> String? {
        guard let inputText = inputText else { return nil }
        let maskText = MaskText(text: inputText, mask: mask)
        return maskText.outputText
    }
    
    static func removeMaskCharacters(text: String, withMask mask: String) -> String {
        var mask = mask
        var text = text
        
        if mask != emptyMask {
            while text.count > mask.count {
                text.removeLast()
            }
        }
        
        mask = mask.replacingOccurrences(of: "X", with: "")
        mask = mask.replacingOccurrences(of: "N", with: "")
        mask = mask.replacingOccurrences(of: "C", with: "")
        mask = mask.replacingOccurrences(of: "c", with: "")
        mask = mask.replacingOccurrences(of: "U", with: "")
        mask = mask.replacingOccurrences(of: "u", with: "")
        mask = mask.replacingOccurrences(of: "*", with: "")
        
        var index = mask.startIndex
        
        while(index != mask.endIndex) {
            text = text.replacingOccurrences(of: "\(mask[index])", with: "")
            index = mask.index(after: index)
        }
        return text
    }
}

class MaskText: NSObject {
    
    var inputText: String = ""

    private var _mask: String = ""
    var mask: String {
        get {
            return _mask
        }
        set {
            _mask = newValue
            applyFilter(text: inputText)
        }
    }
    
    private var _outputText: String = ""
    private(set) var outputText: String {
        set {
            _outputText = newValue
        }
        get {
            applyFilter(text: inputText)
            return _outputText
        }
    }
    
    init(text: String = "", mask: String = "") {
        super.init()
        self.inputText = text
        self.mask = mask
    }
    
    var removeMaskCharacters: String {
        get {
            return MaskText.removeMaskCharacters(text: outputText, withMask: mask)
        }
    }
    
    func applyFilter(text: String) {
        if mask.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) == "" {
            self.outputText = text
            return
        }
        var index = mask.startIndex
        var textWithMask: String = ""
        var i: Int = 0
        
        if (text.isEmpty) {
            self.outputText = text
            return
        }
        
        while(index != mask.endIndex) {
            if (i >= text.count) {
                self.outputText = textWithMask
                break
            }
            switch "\(mask[index])" {
            case "N": // Only number
                guard text[i].isNumber else {
                    i += 1
                    break
                }
                textWithMask = textWithMask + text[i]
                i += 1
            case "C": // Only Characters A-Z, Upper case only
                guard text[i].hasSpecialCharacter, !text[i].isNumber else {
                    i += 1
                    break
                }
                textWithMask = textWithMask + text[i].uppercased()
                i += 1
            case "c": // Only Characters a-z, lower case only
                guard text[i].hasSpecialCharacter, !text[i].isNumber else {
                    i += 1
                    break
                }
                textWithMask = textWithMask + text[i].lowercased()
                i += 1
            case "X": // Only Characters a-Z
                guard text[i].hasSpecialCharacter, !text[i].isNumber else {
                    i += 1
                    break
                }
                textWithMask = textWithMask + text[i]
                i += 1
            case "%": // Characters a-Z + Numbers
                guard text[i].hasSpecialCharacter else {
                    i += 1
                    break
                }
                textWithMask = textWithMask + text[i]
                i += 1
            case "U": // Only Characters A-Z + Numbers, Upper case only
                guard text[i].hasSpecialCharacter else {
                    i += 1
                    break
                }
                textWithMask = textWithMask + text[i].uppercased()
                i += 1
            case "u": // Only Characters a-z + Numbers, lower case only
                guard text[i].hasSpecialCharacter else {
                    i += 1
                    break
                }
                textWithMask = textWithMask + text[i].lowercased()
                i += 1
            case "*": // Any Character
                textWithMask = textWithMask + text[i]
                i += 1
            default:
                textWithMask = textWithMask + "\(mask[index])"
            }
            
            index = mask.index(after: index)
        }
        self.outputText = textWithMask
    }
}
