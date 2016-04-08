import UIKit

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	@IBOutlet var tableView: UITableView?
	var pageViewController: UIPageViewController?
	var viewControllers: [UIViewController]? {
		didSet {
			tableView?.reloadData()
		}
	}

	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let count = viewControllers?.count else {
			return 0
		}

		return count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("menu_cell")!

		if let viewController = viewControllers?[indexPath.row] {
			cell.textLabel?.text = viewController.title
		}

		return cell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		guard let selectedCtrl = viewControllers?[indexPath.row] else {
			return
		}

		pageViewController?.setViewControllers([selectedCtrl],
			direction: .Forward, animated: true, completion: nil)
	}
}
