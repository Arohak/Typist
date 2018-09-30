//
//  ModernToolbarController.swift
//  Zangi
//
//  Created by Admin on 9/28/18.
//  Copyright © 2018 Zangi Livecom Pte. Ltd. All rights reserved.
//

import UIKit

@objc
class ModernToolbarController: NSObject {

    let toolbarPresenter = ToolbarPresenter.shared
    var toolbarContainer: ModernToolbarContainer!
    var vc: UIViewController!
    var scrollView: UIScrollView!
    var container: Container = Container(all: .closed)
    var options: Options = Options()

    @objc
    public override init() {
        super.init()
    }

    @objc
    public init(vc: UIViewController, scrollView: UIScrollView) {
        super.init()
        
        config(vc: vc, scrollView: scrollView)
    }

    @objc
    public func config(vc: UIViewController, scrollView: UIScrollView) {
        self.vc = vc
        self.scrollView = scrollView
        toolbarContainer = ModernToolbarContainer(delegate: self)
        setup()
    }
}

// MARK: - Nested Types
extension ModernToolbarController {
    struct Options {
        var toolbarHeight: CGFloat = 60
        var inset: CGFloat = 10
    }

    struct Container {
        let gallery: State
        let sticker: State

        init(all state: State) {
            gallery = state
            sticker = state
        }

        init(_ galleryState: State, _ stickerState: State) {
            gallery = galleryState
            sticker = stickerState
        }

        var isClosed: Bool {
            return gallery == .closed && sticker == .closed
        }

        var isOpened: Bool {
            return gallery == .opened || sticker == .opened
        }
    }

    enum State {
        case opened
        case closed
    }
}

//MARK: - Setup
extension ModernToolbarController {
    func setup() {
        setupActions()
        setupKeyboard()
    }

    func setupActions() {
        toolbarContainer.toolbarView.sendButton.addTarget(self, action: #selector(tapGifButton(sender:)), for: .touchUpInside)
        toolbarContainer.toolbarView.addButton.addTarget(self, action: #selector(tapGalleryButton(sender:)), for: .touchUpInside)
        toolbarContainer.toolbarView.smileButton.addTarget(self, action: #selector(tapSmileButton(sender:)), for: .touchUpInside)
        toolbarContainer.toolbarView.textView.delegate = self
    }

    func setupKeyboard() {
        toolbarPresenter
            .toolbar(scrollView: scrollView)
            .on(keyboard: .willChangeFrame) { [weak self] options in
                guard let sSelf = self else { return }
                sSelf.updateBottom(with: options.endFrame.height, 0)
            }
            .on(keyboard: .willHide) { [weak self] options in
                guard let sSelf = self else { return }
                if sSelf.container.isClosed {
                    sSelf.updateBottom(with: 0, options.duration, options.curve)
                    sSelf.updateButton(isSelected: false)
                } else {
                    sSelf.updateBottom(with: keyboardDefaulthHeight, keyboardAnimationDuration)
                }
            }
            .on(keyboard: .willShow) { [weak self] _ in
                guard let sSelf = self else { return }
                sSelf.container = Container(all: .closed)
                sSelf.updateButton(isSelected: false)
            }
            .on(gesture: .changed) { [weak self] height in
                guard let sSelf = self else { return }
                if sSelf.toolbarContainer.bottom.constant != 0 {
                    if sSelf.container.isClosed {
                        sSelf.updateBottom(with: height, 0)
                    } else {
                        sSelf.updateBottom(with: 0, keyboardAnimationDuration)
                    }
                }
            }
            .on(gesture: .ended) { [weak self] _ in
                guard let sSelf = self else { return }
                if sSelf.toolbarContainer.bottom.constant != 0 && sSelf.container.isOpened {
                    sSelf.updateBottom(with: 0, keyboardAnimationDuration)
                }
            }
            .start()
    }

    private func updateBottom(with height: CGFloat, _ duration: Double, _ curve: UIViewAnimationCurve = .linear) {
        UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions(curve: curve), animations: {
            self.toolbarContainer.bottom.constant = height
            self.scrollView.contentInset.bottom = height
            self.scrollView.scrollIndicatorInsets.bottom = height
            self.vc.view.layoutIfNeeded()
        }, completion: nil)
    }
}

//MARK: - ModernKeyboardContainerProtocol
extension ModernToolbarController: ModernToolbarContainerProtocol {
    var toolbarHeight: CGFloat {
        return options.toolbarHeight
    }
    
    var inset: CGFloat {
        return options.inset
    }
}

//MARK: - Actions
extension ModernToolbarController {
    @objc func tapGifButton(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        toolbarContainer.gifView.isHidden = !sender.isSelected
    }

    @objc func tapGalleryButton(sender: UIButton) {
        toolbarContainer.galleryView.isHidden = false
        toolbarContainer.stickersParentView.isHidden = true
        tapButton(with: .add, sender: sender)
    }

    @objc func tapSmileButton(sender: UIButton) {
        toolbarContainer.galleryView.isHidden = true
        toolbarContainer.stickersParentView.isHidden = false
        tapButton(with: .smile, sender: sender)
    }
    
    func tapButton(with type: ModernToolbarContainer.ToolbarActionType, sender: UIButton) {
        sender.isSelected = !sender.isSelected

        if sender.isSelected {
            container = type == .add ? Container(.opened, .closed) : Container(.closed, .opened)
            if toolbarContainer.bottom.constant == 0 {
                updateBottom(with: keyboardDefaulthHeight, keyboardAnimationDuration)
            } else {
                toolbarContainer.toolbarView.textView.resignFirstResponder()
            }
        } else {
            container = type == .add ? Container(.closed, .opened) : Container(.opened, .closed)
            toolbarContainer.toolbarView.textView.becomeFirstResponder()
        }
    }

    private func updateButton(isSelected value: Bool) {
        toolbarContainer.toolbarView.addButton.isSelected = value
        toolbarContainer.toolbarView.smileButton.isSelected = value
    }
}

//MARK: - UITextViewDelegate
extension ModernToolbarController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        adjustHeight(for: textView)
    }

    private func adjustHeight(for textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: .greatestFiniteMagnitude))
        let difference = newSize.height - 33 //new line
        guard difference < 40 else { return }
        toolbarContainer.heightConstraint.constant = toolbarHeight + difference
        vc.view.layoutIfNeeded()
    }
}
