//
//  ToolbarView.swift
//  Zangi
//
//  Created by Admin on 9/26/18.
//  Copyright © 2018 Zangi Livecom Pte. Ltd. All rights reserved.
//

import UIKit
import PureLayout

class ToolbarView: UIView {
    
    lazy var addButton: UIButton = {
        let view = UIButton.newAutoLayout()
        view.setTitleColor(.red, for: .normal)
        view.setTitle("+", for: .normal)
        view.setTitle("-", for: .selected)
        return view
    }()
    
    lazy var sendButton: UIButton = {
        let view = UIButton.newAutoLayout()
        view.setTitleColor(.red, for: .normal)
        view.setTitle("-", for: .normal)
        return view
    }()
    
    lazy var bgTextView: UIView = {
        let view = UIView.newAutoLayout()
        view.layer.borderColor = UIColor.gray.cgColor
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 1
        view.clipsToBounds = true
        return view
    }()
    
    lazy var textView: UITextView = {
        let view = UITextView.newAutoLayout()
        view.font = UIFont.systemFont(ofSize: 14)
        view.textColor = .white
        view.backgroundColor = .red
        return view
    }()
    
    lazy var smileButton: UIButton = {
        let view = UIButton.newAutoLayout()
        view.setTitleColor(.red, for: .normal)
        view.setTitle("O", for: .normal)
        view.setTitle("K", for: .selected)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViewConfiguration()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - ViewConfiguration -
extension ToolbarView: ViewConfiguration {
    
    func configureViews() {
        backgroundColor = .yellow
    }
    
    func buildViewHierarchy() {
        addSubview(addButton)
        addSubview(sendButton)
        addSubview(bgTextView)
        bgTextView.addSubview(textView)
        bgTextView.addSubview(smileButton)
    }
    
    func setupConstraints() {
        let insetText: CGFloat = 3
        let inset: CGFloat = 10
        let width: CGFloat = 40
        
        addButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: inset)
        addButton.autoPinEdge(toSuperviewEdge: .left, withInset: inset)
        addButton.autoSetDimensions(to: CGSize(width: width, height: width))
        
        sendButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: inset)
        sendButton.autoPinEdge(toSuperviewEdge: .right, withInset: inset)
        sendButton.autoSetDimensions(to: CGSize(width: width, height: width))
        
        bgTextView.autoPinEdge(toSuperviewEdge: .top, withInset: inset)
        bgTextView.autoPinEdge(toSuperviewEdge: .bottom, withInset: inset)
        bgTextView.autoPinEdge(.left, to: .right, of: addButton, withOffset: inset)
        bgTextView.autoPinEdge(.right, to: .left, of: sendButton, withOffset: -inset)

        textView.autoPinEdge(toSuperviewEdge: .top, withInset: insetText)
        textView.autoPinEdge(toSuperviewEdge: .bottom, withInset: insetText)
        textView.autoPinEdge(toSuperviewEdge: .left, withInset: insetText)
        textView.autoPinEdge(.right, to: .left, of: smileButton, withOffset: -insetText)
        
        smileButton.autoAlignAxis(.horizontal, toSameAxisOf: bgTextView)
        smileButton.autoPinEdge(toSuperviewEdge: .right, withInset: inset)
        smileButton.autoSetDimensions(to: CGSize(width: width, height: width))
    }
}

//MARK: - UITextViewDelegate -
extension ToolbarView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
//        delegate.textDidChange(textView)
    }
}
