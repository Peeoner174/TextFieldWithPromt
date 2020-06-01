//
//  TextViewWithPromt.swift
//  TextFieldWithPromt
//
//  Created by MSI on 02.06.2020.
//  Copyright © 2020 MSI. All rights reserved.
//

import UIKit

@objc protocol TextViewWithPromtDelegate: class {
    @objc optional func textViewWPDidBeginEditing(_ textView: TextViewWithPromt)
    @objc optional func textViewWPDidEndEditing(_ textView: TextViewWithPromt)
    @objc optional func textViewWPShouldReturn(_ textView: TextViewWithPromt) -> Bool
    @objc optional func textViewWP(_ textView: TextViewWithPromt, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    @objc optional func textViewWPShouldBeginEditing(_ textView: TextViewWithPromt)
    @objc optional func textViewWPDidChange(textView: TextViewWithPromt)
}

class TextViewWithPromt: UIView {
    weak var delegate: TextViewWithPromtDelegate?
    
    private var view: UIView!
    @IBOutlet private weak var promtLabel: UILabel!
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private var promtLabelHeightConstraint: NSLayoutConstraint!
    
    /// Colors
    
    @IBInspectable var promtLabelOnFocusColor: UIColor = .black
    @IBInspectable var promtLabelDefaultColor: UIColor = .black
    @IBInspectable var promtLabelOnFailValidationColor: UIColor = .red
    
    @IBInspectable var inputTextOnFocusColor: UIColor = .black
    @IBInspectable var inputTextDefaultColor: UIColor = .black
    @IBInspectable var inputTextFailValidationColor: UIColor = .red
    
    /// Config
    @IBInspectable var promtFontDefault = UIFont.systemFont(ofSize: 17.0, weight: .regular)
    @IBInspectable var promtFontEditing = UIFont.systemFont(ofSize: 11.0, weight: .regular)
    /// Private help config
    private var animationDuration = 0.2
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
    
    @IBInspectable var promtTextColor: UIColor = UIColor(red: 0.78, green: 0.83, blue: 0.87, alpha: 1) {
        didSet {
            promtLabel.textColor = promtTextColor
        }
    }
    
    // MARK: - TextView funcs wrappers
      
    var textColor: UIColor? {
        get {
            return textView.textColor
        }
        set {
            textView.textColor = newValue
        }
    }
    var keyboardType = UIKeyboardType.default {
        didSet {
            textView.keyboardType = keyboardType
        }
    }
    
    var text: String? {
        return textView.text
    }
    
    override var inputView: UIView? {
        get {
            return textView.inputView
        }
        set {
            textView.inputView = newValue
        }
    }
    
    var autocapitalizationType: UITextAutocapitalizationType {
        get {
            return textView.autocapitalizationType
        }
        set {
            textView.autocapitalizationType = newValue
        }
    }
    
    var autocorrectionType: UITextAutocorrectionType {
        get {
            return textView.autocorrectionType
        }
        set {
            textView.autocorrectionType = newValue
        }
    }
    
    @available(iOS 10.0, *)
    var textContentType: UITextContentType {
        get {
            return textView.textContentType
        }
        set {
            textView.textContentType = newValue
        }
    }
    
    func setInputAccessoryView(_ view: UIView) {
        textView.inputAccessoryView = view
    }
    
    // MARK: - On validate events funcs
    
    @objc
    func inputTextValidated(isValid: Bool) {
        if isValid {
            setDefaultColorStyle()
        } else {
            setFailColorStyle()
        }
    }
    
    private func setDefaultColorStyle() {
        promtTextColor = promtLabelDefaultColor
        textColor = inputTextDefaultColor
    }
    
    private func setFocusColorStyle() {
        promtTextColor = promtLabelOnFocusColor
        textColor = inputTextOnFocusColor
    }
    
    private func setFailColorStyle() {
        self.textColor = inputTextFailValidationColor
        self.promtTextColor = promtLabelOnFailValidationColor
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
        
        textView.font = UIFont.systemFont(ofSize: 17.0, weight: .regular)
        
        let gr = UITapGestureRecognizer()
        gr.addTarget(self, action: #selector(didTapOnView))
        view.addGestureRecognizer(gr)
        
        textView.delegate = self
        addSubview(view)
    }
    
    fileprivate func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: TextViewWithPromt.self)
        let nib = UINib(nibName: "TextViewWithPromt", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    // MARK: - Actions
    @objc fileprivate func didTapOnView() {
        textView.becomeFirstResponder()
    }
    
    // MARK: - Public setup methods
    func addRightButton(withTitle title: String, target: Any?, action: Selector?) {
        let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 49)))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let rightButton = UIBarButtonItem(title: title, style: .done, target: target, action: action)
        toolbar.items = [space, rightButton]
        toolbar.sizeToFit()
        textView.inputAccessoryView = toolbar
    }
    
    func setText(_ text: String?, animated: Bool = false) {
        if textView.isFirstResponder {
            textView.text = text
            return
        }
        textView.text = text
        let isEmptyText = text?.isEmpty != false
        
        promtLabelHeightConstraint.isActive = isEmptyText
        promtLabel.font = isEmptyText ? promtFontDefault : promtFontEditing.withSize(promtFontDefault.pointSize)
        
        if animated {
            UIView.animate(withDuration: animationDuration) { [weak self] in
                guard let weakSelf = self else { return }
                weakSelf.view.layoutIfNeeded()
                weakSelf.promtLabel.frame.origin.x = 0
                if isEmptyText {
                    weakSelf.transformPromtToNormal()
                } else {
                    weakSelf.scalePromtDown()
                }
            }
        } else {
            view.layoutIfNeeded()
            promtLabel.frame.origin.x = 0
            if isEmptyText {
                transformPromtToNormal()
            } else {
                scalePromtDown()
            }
        }
    }
}

// MARK: - UITextViewDelegate
extension TextViewWithPromt: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        delegate?.textViewWPDidChange?(textView: self)
    }

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        delegate?.textViewWPShouldBeginEditing?(self)
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        setFocusColorStyle()
        guard textView.text?.isEmpty != false else {
            delegate?.textViewWPDidBeginEditing?(self)
            return
        }
        promtLabelHeightConstraint.isActive = false
        promtLabel.font = promtFontEditing.withSize(promtFontDefault.pointSize)
        UIView.animate(withDuration: animationDuration, animations: { [weak self] in
            guard let self = self else { return }
            self.view.layoutIfNeeded()
            self.scalePromtDown()
            self.setFocusColorStyle()
        }) { [weak self] (_) in
            guard let weakSelf = self else { return }
            weakSelf.delegate?.textViewWPDidBeginEditing?(weakSelf)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.textViewWPDidEndEditing?(self)
        guard textView.text?.isEmpty != false else { return }
        promtLabelHeightConstraint.isActive = true
        promtLabel.font = promtFontDefault
        UIView.animate(withDuration: animationDuration) { [weak self] in
            self?.view.layoutIfNeeded()
            self?.transformPromtToNormal()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let result = delegate?.textViewWP?(self, shouldChangeCharactersIn: range, replacementString: text) else {
            return true
        }
        return result
    }
}

