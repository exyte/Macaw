import UIKit

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	@IBOutlet var tableView: UITableView?
	var pageViewController: UIPageViewController?
	var viewControllers: [UIViewController]? {
		didSet {
			tableView?.reloadData()
		}
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let count = viewControllers?.count else {
			return 0
		}

		return count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "menu_cell")!

		if let viewController = viewControllers?[(indexPath as NSIndexPath).row] {
			cell.textLabel?.text = viewController.title
		}

		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let selectedCtrl = viewControllers?[(indexPath as NSIndexPath).row] else {
			return
		}

		pageViewController?.setViewControllers([selectedCtrl],
			direction: .forward, animated: true, completion: nil)
	}
}
