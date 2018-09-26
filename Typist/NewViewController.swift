//
//  newViewController.swift
//  Typist-Demo
//
//  Created by Ara Hakobyan on 27/09/2018.
//  Copyright © 2018 Toto Tvalavadze. All rights reserved.
//

import UIKit

class NewViewController: UIViewController {

    let keyboard = Typist.shared

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var toolbarView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var bottom: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        keyboard
            .toolbar(scrollView: tableView)
            .on(event: .willChangeFrame) { [unowned self] options in
                let height = options.endFrame.height + 60
                UIView.animate(withDuration: 0) {
                    self.update(with: height)
                }
                self.navigationItem.prompt = options.endFrame.debugDescription
            }
            .on(event: .willHide) { [unowned self] options in
                UIView.animate(withDuration: options.animationDuration, delay: 0, options: UIViewAnimationOptions(curve: options.animationCurve), animations: {
                    self.update(with: 0)
                }, completion: nil)
            }
            .start()

        self.navigationItem.prompt = "Keybaord frame will appear here."
        self.title = "Typist Demo"
    }

    private func update(with height: CGFloat) {
        self.bottom.constant = max(0, height - self.toolbarView.bounds.height)
        self.tableView.contentInset.bottom = max(self.toolbarView.bounds.height, height)
        self.tableView.scrollIndicatorInsets.bottom = max(self.toolbarView.bounds.height, height)
        self.toolbarView.layoutIfNeeded()
    }
}

extension NewViewController: UITableViewDataSource, UITableViewDelegate {

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
        self.textField.resignFirstResponder()
    }

}

