import UIKit

open class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	@IBOutlet var tableView: UITableView?
    
    fileprivate var viewControllers = [
        "FirstPageViewController",
        "TransformExampleController",
        "AnimationsExampleController",
        "SVGExampleViewController",
        "EasingExampleController",
        "MorphingExampleController",
        "EventsExampleController"
    ].map {
        UIStoryboard(name: "Main", bundle: .none).instantiateViewController(withIdentifier: $0)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView?.reloadData()
    }

	open func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewControllers.count
	}

	open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "menu_cell")!
        cell.textLabel?.text = viewControllers[indexPath.row].title
		return cell
	}

	open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.navigationController?.pushViewController(viewControllers[indexPath.row], animated: true)
	}
    
}
