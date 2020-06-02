//
//  TextFieldWithPromt.swift
//  TextFieldWithPromt
//
//  Created by MSI on 02.06.2020.
//  Copyright © 2020 MSI. All rights reserved.
//

import UIKit

@objc public protocol TextFieldWithPromtDelegate: class {
    @objc optional func textFieldWPDidBeginEditing(_ textField: TextFieldWithPromt)
    @objc optional func textFieldWPDidEndEditing(_ textField: TextFieldWithPromt)
    @objc optional func textFieldWPShouldReturn(_ textField: TextFieldWithPromt) -> Bool
    @objc optional func textFieldWP(_ textField: TextFieldWithPromt, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    @objc optional func textFieldWPShouldBeginEditing(_ textField: TextFieldWithPromt)
}

public class TextFieldWithPromt: UIView {
    weak var delegate: TextFieldWithPromtDelegate?
    weak var maskTemplate_delegate: MaskTemplate_TextFieldDelegate?
    
    lazy var maskTemplate: MaskTemplate = {
        let value = MaskTemplate(cursorColor: self.textField.tintColor)
        value.inputTextColor = .black
        self.maskTemplate_delegate = value
        return value
    }()

    private var view: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var promtLabel: UILabel!
    @IBOutlet private var promtLabelCenterConstraint: NSLayoutConstraint!
    
    /// Colors
    
    @IBInspectable var templateOnFocusColor: UIColor = .black
    @IBInspectable var templateDefaultColor: UIColor = .black
    @IBInspectable var templateOnFailValidationColor: UIColor = .red
    
    @IBInspectable var inputTextOnFocusColor: UIColor = .black
    @IBInspectable var inputTextDefaultColor: UIColor = .black
    @IBInspectable var inputTextFailValidationColor: UIColor = .red
    
    @IBInspectable var promtLabelOnFocusColor: UIColor = .black
    @IBInspectable var promtLabelDefaultColor: UIColor = .black
    @IBInspectable var promtLabelOnFailValidationColor: UIColor = .red
    
    // MARK: - Additional
    
    /// For datePicker input type
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return datePicker
    }()
    
    @objc private func dateChanged() {
        setText(datePicker.date.toString(.dotFormatDate))
    }
    
    /// For pickerView input type
    lazy var pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.backgroundColor = .white
        return picker
    }()
    
    // MARK: - Input text mask logic
    
    @IBInspectable var maskString: String {
        get {
            return maskTemplate.mask
        }
        set {
            maskTemplate.mask = newValue
            setText(self.maskTemplate.inputTextWithoutMask, animated: true)
        }
    }
    
    // MARK: - Validate logic
    
    func inputTextValidated(_ isValid: Bool) {
        if isValid {
            setDefaultColorStyle()
        } else {
            setFailValidationColorStyle()
        }
    }
    
    func setDefaultColorStyle() {
        promtTextColor = promtLabelDefaultColor
        maskTemplate.inputTextColor = inputTextDefaultColor
        maskTemplate.templateColor = templateDefaultColor
    }
    
    func setFailValidationColorStyle() {
        maskTemplate.inputTextColor = inputTextFailValidationColor
        maskTemplate.templateColor = templateOnFailValidationColor
        promtTextColor = promtLabelOnFailValidationColor
    }
    
    func setFocusColorStyle() {
        promtTextColor = promtLabelOnFocusColor
        maskTemplate.inputTextColor = inputTextOnFocusColor
        maskTemplate.templateColor = templateOnFocusColor
    }
    
    /// Config
    
    @IBInspectable var promtFontDefault = UIFont.systemFont(ofSize: 17.0, weight: .regular)
    @IBInspectable var promtFontEditing = UIFont.systemFont(ofSize: 11.0, weight: .regular)
    
    /// Private help config
    
    private var animationDuration = 0.1
    private var promtScale: CGFloat {
        return promtFontEditing.pointSize / promtFontDefault.pointSize
    }
    
    private var promtIsShrunk: Bool {
        return promtLabel.transform != CGAffineTransform.identity
    }
    
    private var scaledDownPromtTransform: CGAffineTransform {
        let promtRect = promtLabel.frame
        let destinationRect = CGRect(x: 0, y: 9, width: promtRect.width * promtScale, height: promtRect.height * promtScale)
        return CGAffineTransform.transformFromRect(from: promtRect, toRect: destinationRect)
    }
    
    private func transformPromtToNormal() {
        promtLabel.transform = CGAffineTransform.identity
        promtLabel.frame.origin.x = 0
        promtLabel.frame.origin.y = 22
    }
    
    private func scalePromtDown() {
        guard !promtIsShrunk else { return }
        promtLabel.transform = scaledDownPromtTransform
    }
    
    // MARK: - UILabel funcs wrappers
    
    @IBInspectable var promtText: String? {
         didSet {
             promtLabel.text = promtText
         }
     }
    
    @IBInspectable var promtTextColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)  {
         didSet {
             promtLabel.textColor = promtTextColor
         }
     }
    
    // MARK: - TextField funcs wrappers

    var textColor: UIColor? {
        get {
            return self.maskTemplate.inputTextColor
        }
        set {
            self.maskTemplate.inputTextColor = newValue ?? .black
        }
    }
    
    var keyboardType = KeyboardType.default {
        didSet {
            if let keyboardType = self.keyboardType.asUIKeyboardType() {
                textField.keyboardType = keyboardType
                textField.tintColor = .blue
                return
            } else if self.keyboardType == .datePicker {
                textField.tintColor = .clear
                textField.inputView = self.datePicker
            } else if self.keyboardType == .picker {
                textField.inputView = self.pickerView
                textField.tintColor = .clear
            }
        }
    }
    
    var text: String? {
        return maskTemplate.inputTextWithoutMask
    }
    
    var isActive: Bool = true {
        didSet {
            textField.isEnabled = isActive
        }
    }
    
    public override var inputView: UIView? {
        get {
            return textField.inputView
        }
        set {
            textField.inputView = newValue
        }
    }
    
    var autocapitalizationType: UITextAutocapitalizationType {
        get {
            return textField.autocapitalizationType
        }
        set {
            textField.autocapitalizationType = newValue
        }
    }
    
    var autocorrectionType: UITextAutocorrectionType {
        get {
            return textField.autocorrectionType
        }
        set {
            textField.autocorrectionType = newValue
        }
    }
    
    @available(iOS 10.0, *)
    var textContentType: UITextContentType {
        get {
            return textField.textContentType
        }
        set {
            textField.textContentType = newValue
        }
    }
    
    func setInputAccessoryView(_ view: UIView) {
        textField.inputAccessoryView = view
    }
    
    // MARK: Lifecycle methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    // MARK: - Setup methods
    
    fileprivate func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let gr = UITapGestureRecognizer()
        gr.addTarget(self, action: #selector(didTapOnView))
        view.addGestureRecognizer(gr)
    
        textField.delegate = self
        addSubview(view)
    }
    
    fileprivate func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: TextFieldWithPromt.self)
        let nib = UINib(nibName: "TextFieldWithPromt", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    // MARK: - Actions
    
    @objc fileprivate func didTapOnView() {
        textField.becomeFirstResponder()
    }
    
    // MARK: - Public setup methods
    
    func addRightButton(withTitle title: String, target: Any?, action: Selector?) {
        let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 49)))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let rightButton = UIBarButtonItem(title: title, style: .done, target: target, action: action)
        toolbar.items = [space, rightButton]
        toolbar.sizeToFit()
        textField.inputAccessoryView = toolbar
    }
    
    func setText(_ text: String?, animated: Bool = false) {
        if textField.isFirstResponder {
            textField.text = text
            return
        }
        maskTemplate.update(inputText: text ?? "")
        textField.text = maskTemplate.inputTextWithMask
        
        let isEmptyText = text?.isEmpty != false
        promtLabelCenterConstraint.isActive = isEmptyText
        promtLabel.font = isEmptyText ? promtFontDefault : promtFontEditing.withSize(promtFontDefault.pointSize)
        
        if animated {
            UIView.animate(withDuration: animationDuration) { [weak self] in
                guard let self = self else { return }
                self.view.layoutIfNeeded()
                self.promtLabel.frame.origin.x = 0
                if isEmptyText {
                    self.transformPromtToNormal()
                    self.promtLabel.frame.origin.y = 22
                } else {
                    self.scalePromtDown()
                    self.promtLabel.frame.origin.y = 9
                }
            }
        } else {
            view.layoutIfNeeded()
            promtLabel.frame.origin.x = 0
            if isEmptyText {
                transformPromtToNormal()
                promtLabel.frame.origin.y = 22
            } else {
                promtLabel.frame.origin.y = 9
                scalePromtDown()
            }
        }
    }
}

// MARK: - UITextFieldDelegate

extension TextFieldWithPromt: UITextFieldDelegate {
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        delegate?.textFieldWPShouldBeginEditing?(self)
        return true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        
        guard textField.text?.isEmpty ?? true else {
            delegate?.textFieldWPDidBeginEditing?(self)
            maskTemplate_delegate?.textFieldDidBeginEditing(textField)
            return
        }
        promtLabelCenterConstraint.isActive = false
        promtLabel.font = promtFontEditing.withSize(promtFontDefault.pointSize)
        UIView.animate(withDuration: animationDuration, animations: { [weak self] in
            guard let self = self else { return }
            self.view.layoutIfNeeded()
            self.scalePromtDown()
        }) { [weak self] (_) in
            guard let self = self else { return }
            self.delegate?.textFieldWPDidBeginEditing?(self)
            self.maskTemplate_delegate?.textFieldDidBeginEditing(textField)
            
            if self.maskTemplate.template == .phone { self.maskTemplate.inputTextWithMask = "+7 (" }
        }
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        maskTemplate_delegate?.textFieldDidEndEditing(textField)
        delegate?.textFieldWPDidEndEditing?(self)
        guard textField.text?.isEmpty ?? true else {
            return
        }
        promtLabelCenterConstraint.isActive = true
        promtLabel.font = promtFontDefault
        UIView.animate(withDuration: animationDuration) { [weak self] in
            self?.view.layoutIfNeeded()
            self?.transformPromtToNormal()
        }
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let result = delegate?.textFieldWPShouldReturn?(self) else {
            return false
        }
        return result
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if maskTemplate.template == .phone && self.text?.onlyDigits.count ?? 0 == 1 && string == "" {
            guard let cursorPosition = textField.position(from: textField.beginningOfDocument, offset: 4) else {
                return false
            }
            textField.selectedTextRange = textField.textRange(from: cursorPosition, to: cursorPosition)
            return false
        }
        
        let maskTemplateDelegateResult = maskTemplate_delegate?.textField(textField, shouldChangeCharactersIn: range, replacementString: string)
        let delegateResult = delegate?.textFieldWP?(self, shouldChangeCharactersIn: range, replacementString: string)
        let isShouldChangeCharacters = delegateResult ?? true && maskTemplateDelegateResult ?? true
        return isShouldChangeCharacters
    }
}

