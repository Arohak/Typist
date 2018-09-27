//
//  ModernViewViewController.swift
//  Zangi
//
//  Created by Admin on 9/27/18.
//  Copyright © 2018 Zangi Livecom Pte. Ltd. All rights reserved.
//

import UIKit
import PureLayout

class ModernViewController: UIViewController {
    var isShowParent = false
    var bottom: NSLayoutConstraint!
    let toolBarHeight: CGFloat = 60

    lazy var tableView: UITableView = {
        let view = UITableView.newAutoLayout()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var toolbarView: UIView = {
        let view = UIView.newAutoLayout()
        view.backgroundColor = .orange
        return view
    }()

    lazy var textView: UITextView = {
        let view = UITextView.newAutoLayout()
        view.backgroundColor = .red
        return view
    }()

    lazy var button: UIButton = {
        let view = UIButton.newAutoLayout()
        view.addTarget(self, action: #selector(tapButton), for: .touchUpInside)
        view.setTitle("O", for: .normal)
        view.setTitle("K", for: .selected)
        return view
    }()

    lazy var parentView: UIView = {
        let view = UIView.newAutoLayout()
        view.backgroundColor = .lightGray
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewConfiguration()
        setupKeyboard()
    }
}

//MARK: - Actions -
extension ModernViewController {
    @objc func tapButton(sender: UIButton) {
        sender.isSelected = !sender.isSelected

        if sender.isSelected {
            if bottom.constant == 0 {
                UIView.animate(withDuration: 0.25) {
                    self.bottom.constant = self.toolBarHeight * 5
                    self.view.layoutIfNeeded()
                }
            } else {
                isShowParent = true
                textView.resignFirstResponder()
            }
        } else {
            isShowParent = false
            textView.becomeFirstResponder()
        }
    }
}

//MARK: - Setup Keyboard -
extension ModernViewController {
    func setupKeyboard() {
        Typist.shared
            .toolbar(scrollView: tableView)
            .on(event: .willChangeFrame) { [unowned self] options in
                let height = options.endFrame.height
                UIView.animate(withDuration: 0) {
                    if !self.isShowParent {
                        self.bottom.constant = height
                        self.view.layoutIfNeeded()
                    }
                }
            }
            .on(event: .willHide) { [unowned self] options in
                UIView.animate(withDuration: options.animationDuration, delay: 0, options: UIViewAnimationOptions(curve: options.animationCurve), animations: {
                    if !self.isShowParent {
                        self.bottom.constant = 0
                        self.view.layoutIfNeeded()
                        self.button.isSelected = false
                    }
                }, completion: nil)
            }
            .on(event: .willShow) { [unowned self] _ in
                self.button.isSelected = false
            }
            .start()
    }
}

//MARK: - ViewConfiguration -
extension ModernViewController: ViewConfiguration {
    func configureViews() {
        view.backgroundColor = .yellow
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func buildViewHierarchy() {
        view.addSubview(tableView)
        view.addSubview(toolbarView)
        toolbarView.addSubview(textView)
        toolbarView.addSubview(button)
        view.addSubview(parentView)
    }

    func setupConstraints() {
        tableView.autoPinEdge(toSuperviewEdge: .top)
        tableView.autoPinEdge(toSuperviewEdge: .left)
        tableView.autoPinEdge(toSuperviewEdge: .right)
        tableView.autoPinEdge(.bottom, to: .top, of: toolbarView)

        toolbarView.autoSetDimension(.height, toSize: toolBarHeight)
        toolbarView.autoPinEdge(toSuperviewEdge: .left)
        toolbarView.autoPinEdge(toSuperviewEdge: .right)
        bottom = NSLayoutConstraint(item: bottomLayoutGuide,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: toolbarView,
                                     attribute: .bottom,
                                     multiplier: 1,
                                     constant: 0)
        view.addConstraint(bottom)

        textView.autoPinEdgesToSuperviewMargins()

        button.autoPinEdge(toSuperviewEdge: .right)
        button.autoAlignAxis(toSuperviewAxis: .horizontal)
        button.autoSetDimensions(to: CGSize(width: 40, height: 40))

        parentView.autoPinEdge(.top, to: .bottom, of: toolbarView)
        parentView.autoPinEdge(toSuperviewEdge: .left)
        parentView.autoPinEdge(toSuperviewEdge: .right)
        parentView.autoSetDimension(.height, toSize: toolBarHeight*4)
    }
}

//MARK: - UITableViewDataSource, UITableViewDelegate -
extension ModernViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.textLabel?.text = "Cell \(indexPath.row)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        textView.resignFirstResponder()
        isShowParent = false
    }

}
