//
//  PinCodeView.swift
//  PinCodeView
//
//  Created by Ariel Pollack on 02/04/2017.
//  Copyright © 2017 Dapulse. All rights reserved.
//

import UIKit

public enum PinCodeDigitViewState {
    case empty
    case hasDigit
    case failedVerification
}

fileprivate func ==(lhs: PinCodeView.State, rhs: PinCodeView.State) -> Bool {
    switch (lhs, rhs) {
    case (.inserting(let index1), .inserting(let index2)):
        return index1 == index2
        
    case (.finished, .finished),
         (.loading, .loading),
         (.disabled, .disabled):
        return true
        
    default:
        return false
    }
}

@objc public class PinCodeView: UIStackView {
    
    public enum TextType {
        case numbers
        case numbersAndLetters
    }
    
    fileprivate enum State: Equatable {
        case inserting(Int)
        case loading
        case finished
        case disabled
    }
    
    @objc public weak var delegate: PinCodeViewDelegate?
    
    /// support numbers and alphanumeric
    public var textType: TextType = .numbers
    
    /// initializer for the single digit views
    public var digitViewInit: (() -> PinCodeDigitView)!
    
    /// pretty straightforward
    @objc public var numberOfDigits: Int = 6
    
    /// group size for separating digits
    /// for example:
    /// group size of 3 will give ___ - ___
    @objc public var groupingSize: Int = 3
    
    /// space between items
    @objc public var itemSpacing: Int = 2
    
    private var previousDigitState: State?
    public var isEnabled: Bool {
        get { return digitState != .disabled }
        set {
            if newValue == isEnabled { return }
            
            if !newValue {
                previousDigitState = digitState
                digitState = .disabled
            } else if let previousState = previousDigitState {
                digitState = previousState
            }
        }
    }
    
    fileprivate var digitViews = [PinCodeDigitView]()
    fileprivate var digitState: State = .inserting(0) {
        didSet {
            if case .inserting(0) = digitState {
                clearText()
            }
        }
    }
    
    public init(numberOfDigits: Int = 6, textType: TextType = .numbers, groupingSize: Int = 3, itemSpacing: Int = 2) {
        super.init(frame: .zero)
        
        self.numberOfDigits = numberOfDigits
        self.textType = textType
        self.groupingSize = groupingSize
        self.itemSpacing = itemSpacing
        
        configure()
    }
    
    @objc override public init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    @objc required public init(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure() {
        self.axis = .horizontal
        self.distribution = .fill
        self.translatesAutoresizingMaskIntoConstraints = false
        
        configureGestures()
    }
    
    private func configureGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tap)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress))
        longPress.minimumPressDuration = 0.25
        addGestureRecognizer(longPress)
    }
    
    private func configureDigitViews() {
        assert(digitViewInit != nil, "must provide a single digit view initializer")
        
        self.spacing = CGFloat(itemSpacing)
        
        self.arrangedSubviews.forEach { view in
            self.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        digitViews = []
        
        for _ in 0..<numberOfDigits {
            let digitView = digitViewInit()
            digitView.view.translatesAutoresizingMaskIntoConstraints = false
            self.addArrangedSubview(digitView.view)
            digitViews.append(digitView)
        }
        
        if groupingSize > 0 {
            // TODO: better custom separators
            for idx in stride(from: groupingSize, to: numberOfDigits, by: groupingSize).reversed() {
                let separator = PinCodeSeparatorView(text: "-")
                self.insertArrangedSubview(separator, at: idx)
            }
        }
    }
    
    private var didLayoutSubviews = false
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if !didLayoutSubviews {
            didLayoutSubviews = true
            configureDigitViews()
        }
    }
    
    @objc func didTap() {
        guard !self.isFirstResponder else { return }
        becomeFirstResponder()
    }
    
    @objc func didLongPress(gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        if !self.isFirstResponder  {
            self.becomeFirstResponder()
        }
        
        UIMenuController.shared.setTargetRect(self.bounds, in: self)
        UIMenuController.shared.setMenuVisible(true, animated: true)
    }
    
    // MARK: handle text input
    fileprivate var text: String {
        return digitViews.reduce("", { text, digitView in
            return text + (digitView.digit ?? "")
        })
    }
    
    public func resetDigits() {
        digitState = .inserting(0)
    }
    
    func clearText() {
        for digitView in digitViews {
            digitView.digit = nil
        }
    }
    
    fileprivate var canReceiveText: Bool {
        return [.loading, .disabled].contains(digitState) == false
    }
    
    func submitDigits() {
        digitState = .loading
        
        delegate?.pinCodeView(self, didSubmitPinCode: text, isValidCallback: { [weak self] (isValid) in
            // we don't care about valid, the delegate will do something
            guard !isValid, let zelf = self else { return }
            
            if zelf.digitState == .loading {
                zelf.digitState = .finished
            } else {
                zelf.previousDigitState = .finished
            }
            
            for digitView in zelf.digitViews {
                digitView.state = .failedVerification
            }
            
            zelf.animateFailure()
        })
    }
    
    private func animateFailure() {
        let anim = CABasicAnimation(keyPath: "position")
        anim.fromValue = NSValue(cgPoint: CGPoint(x: center.x - 5, y: center.y))
        anim.toValue = NSValue(cgPoint: CGPoint(x: center.x + 5, y: center.y))
        anim.duration = 0.07
        anim.repeatCount = 2
        anim.autoreverses = true
        layer.add(anim, forKey: "position")
    }
}

extension PinCodeView {
    override public func paste(_ sender: Any?) {
        guard let string = UIPasteboard.general.string else { return }
        let text: String
        switch textType {
        case .numbers:
            text = string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            
        case .numbersAndLetters:
            text = string.components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
        }
        
        let index = text.index(text.startIndex, offsetBy: min(numberOfDigits, text.count))
        insertText(String(text[..<index]))
    }
    
    override public var canBecomeFirstResponder: Bool {
        return canReceiveText
    }
    
    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return canReceiveText && action == #selector(paste(_:))
    }
    
    public var keyboardType: UIKeyboardType {
        get {
            switch textType {
            case .numbers:
                return .numberPad
                
            case .numbersAndLetters:
                return .default
            }
        }
        set {
            // ignore manual user set
        }
    }
}

extension PinCodeView: UIKeyInput {
    public var hasText: Bool {
        return !text.isEmpty
    }
    
    private func isValidText(_ text: String) -> Bool {
        guard !text.isEmpty else {
            return false
        }
        
        let validCharacterSet: CharacterSet
        switch textType {
        case .numbers:
            validCharacterSet = .decimalDigits
            
        case .numbersAndLetters:
            validCharacterSet = .alphanumerics
        }
        
        guard let scalar = UnicodeScalar(text),
            validCharacterSet.contains(scalar) else {
                return false
        }
        
        return true
    }
    
    public func insertText(_ text: String) {
        guard canReceiveText else { return }
        
        // if inserting more than 1 character, reset all values and put new text
        guard text.count == 1 else {
            digitState = .inserting(0)
            text.map({ "\($0)" }).forEach(insertText)
            return
        }
        
        guard isValidText(text) else { return }
        
        delegate?.pinCodeView(self, didInsertText: text)
        
        // state machine
        switch digitState {
        case .inserting(let digitIndex):
            let digitView = digitViews[digitIndex]
            digitView.digit = text
            
            if digitIndex + 1 == numberOfDigits {
                digitState = .finished
                submitDigits()
            } else {
                digitState = .inserting(digitIndex + 1)
            }
            
        case .finished:
            digitState = .inserting(0)
            insertText(text)
            
        default: break
        }
        
    }
    
    public func deleteBackward() {
        guard canReceiveText else { return }
        
        delegate?.pinCodeView(self, didInsertText: "")
        
        switch digitState {
        case .inserting(let index) where index > 0:
            let digitView = digitViews[index - 1]
            digitView.digit = nil
            
            digitState = .inserting(index - 1)
            
        case .finished:
            digitState = .inserting(0)
            
        default: break
        }
    }
}
