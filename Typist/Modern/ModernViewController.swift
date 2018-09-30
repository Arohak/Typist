
import UIKit

class ModernViewController: UIViewController {

    let height: CGFloat = 60

    lazy var toolbarController: ModernToolbarController = {
        let controller = ModernToolbarController()
        controller.options.toolbarHeight = height
        return controller
    }()

    lazy var tableView: UITableView = {
        let view = UITableView.newAutoLayout()
        self.view.addSubview(view)
        view.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: height, right: 0))
        view.dataSource = self
        view.delegate = self
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        toolbarController.config(vc: self, scrollView: self.tableView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        toolbarController.toolbarContainer.toolbarView.textView.resignFirstResponder()
        toolbarController.container = ModernToolbarController.Container(all: .closed)
    }
}
