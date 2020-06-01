//
//  MaskTemplate.swift
//  TextFieldWithPromt
//
//  Created by MSI on 02.06.2020.
//  Copyright © 2020 MSI. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Templates

enum Template: String {
    case phone = "+7 (___) ___ __ __"
    case empty = ""
}

class MaskTemplate: NSObject {
    
    // MARK: Init Properties
    
    var template: Template = .empty
    var mask: String = ""
    
    // MARK: Init
    
    init(template: Template = .empty, mask: String = "", cursorColor: UIColor) {
        self.template = template
        self.mask = mask
        self.cursorColor_storage = cursorColor
        super.init()
    }
    
    func update(_ template: Template) {
        self.template = template
    }
    
    func update(inputText text: String) {
        self.inputTextWithoutMask = MaskText.removeMaskCharacters(text: text, withMask: mask)
    }
    
    // MARK: Properties
    
    private var _inputTextWithMask = ""
    var inputTextWithMask: String {
        get {
            if template == .phone && _inputTextWithMask.count <= "+7 (".count {
                return "+7 ("
            } else {
                return _inputTextWithMask
            }
        }
        set {
           _inputTextWithMask = newValue
        }
    }
    
    var inputTextWithoutMask: String = "" {
        didSet {
            let maskText = MaskText(text: self.inputTextWithoutMask, mask: mask)
            self.inputTextWithMask = maskText.outputText
            if self.inputTextWithoutMask != maskText.removeMaskCharacters {
                self.inputTextWithoutMask = maskText.removeMaskCharacters
            }
        }
    }
    
    var templateColor: UIColor {
        set {
            templateAttributes[.foregroundColor] = newValue
        }
        get {
            templateAttributes[.foregroundColor] as! UIColor
        }
    }
    
    var inputTextColor: UIColor {
        set {
            inputTextAttributes[.foregroundColor] = newValue
        }
        get {
            inputTextAttributes[.foregroundColor] as! UIColor
        }
    }
        
    // MARK: - Private Properties
    
    private var templateAttributes: [NSAttributedString.Key : Any] = [:]
    private var inputTextAttributes: [NSAttributedString.Key : Any] = [:]
    private var cursorColor_storage: UIColor
    
    // MARK: Private
    
    private func updateCursorPosition(for textField: UITextField) {
        guard let cursorPosition = textField.position(from: textField.beginningOfDocument, offset: inputTextWithMask.count) else {
            return
        }
        textField.selectedTextRange = textField.textRange(from: cursorPosition, to: cursorPosition)
    }
    
    private func setCombinedText(for textField: UITextField) {
        let templateSubstring = template.rawValue[inputTextWithMask.endIndex...]
        let attributedString = NSMutableAttributedString(string: inputTextWithMask + templateSubstring, attributes: templateAttributes)
        attributedString.addAttributes(inputTextAttributes, range: NSMakeRange(0, inputTextWithMask.count))
        textField.attributedText = attributedString
    }
}

protocol MaskTemplate_TextFieldDelegate: class {
    func textFieldDidBeginEditing(_ textField: UITextField)
    func textFieldDidEndEditing(_ textField: UITextField)
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    func getTextWithoutTemplate() -> String
}

extension MaskTemplate: MaskTemplate_TextFieldDelegate {
    func getTextWithoutTemplate() -> String {
        return inputTextWithMask
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: { [weak self] in
            guard let self = self, self.inputTextWithMask.count <= self.template.rawValue.count else {
                return
            }
            self.setCombinedText(for: textField)
            self.cursorColor_storage = textField.tintColor
            textField.tintColor = .clear
        })
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        checkOnPreffilledText()
        
        if string == "" {
            onDeleteAction()
        } else {
            if mask != emptyMask && range.location > mask.count {
                return false
            }
            onAppendAction(appendedString: string)
        }
        
        if inputTextWithMask.count <= template.rawValue.count {
            setCombinedText(for: textField)
            updateCursorPosition(for: textField)
            return false
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: { [weak self] in
            guard let self = self, self.inputTextWithMask.count <= self.template.rawValue.count else {
                return
            }
            self.setCombinedText(for: textField)
            self.updateCursorPosition(for: textField)
            textField.tintColor = self.cursorColor_storage
        })
    }
}

// MARK: ShouldChangeCharactersIn helpers function

extension MaskTemplate {
        
    private func onDeleteAction() {
        if inputTextWithoutMask.count > 0 {
            inputTextWithoutMask = inputTextWithoutMask.substring(to: inputTextWithoutMask.index(before: inputTextWithoutMask.endIndex))
        }
    }
    private func onAppendAction(appendedString string: String) {
        inputTextWithoutMask += string
    }
    
    private func checkOnPreffilledText() {
        if MaskText.removeMaskCharacters(text: inputTextWithMask, withMask: mask) != inputTextWithoutMask {
            inputTextWithoutMask = MaskText.removeMaskCharacters(text: inputTextWithMask, withMask: mask)
        }
    }
}


