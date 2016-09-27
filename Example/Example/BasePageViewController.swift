import UIKit
import Foundation

class BasePageViewController: UIPageViewController {

	fileprivate lazy var orderedViewControllers: [UIViewController] = {
		return [
			self.newMacawViewController("MenuViewController"),
			self.newMacawViewController("FirstPageViewController"),
			self.newMacawViewController("SecondPageViewController"),
			self.newMacawViewController("PathExampleController"),
			self.newMacawViewController("TransformExampleController"),
			self.newMacawViewController("FourthPageViewController"),
			self.newMacawViewController("AnimationsExampleController"),
			self.newMacawViewController("ModelListenersExampleController"),
			self.newMacawViewController("SVGExampleViewController"),
			self.newMacawViewController("SVGChartsViewController"),
			self.newMacawViewController("EventsViewController")
		]
	}()

	fileprivate func newMacawViewController(_ controllerName: String) -> UIViewController {
		return UIStoryboard(name: "Main", bundle: nil)
			.instantiateViewController(withIdentifier: controllerName)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		dataSource = self

		if let firstViewController = orderedViewControllers.first {
			setViewControllers([firstViewController],
				direction: .forward,
				animated: true,
				completion: nil)
		}

		if let menuCtrl = orderedViewControllers.first as? MenuViewController {
			menuCtrl.viewControllers = orderedViewControllers.filter { $0 != menuCtrl }
			menuCtrl.pageViewController = self
		}
	}
}

extension BasePageViewController: UIPageViewControllerDataSource {

	func pageViewController(_ pageViewController: UIPageViewController,
		viewControllerBefore viewController: UIViewController) -> UIViewController? {
			guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
				return nil
			}

			let previousIndex = viewControllerIndex - 1

			// User is on the first view controller and swiped left to loop to
			// the last view controller.
			guard previousIndex >= 0 else {
				return orderedViewControllers.last
			}

			guard orderedViewControllers.count > previousIndex else {
				return nil
			}

			return orderedViewControllers[previousIndex]
	}

	func pageViewController(_ pageViewController: UIPageViewController,
		viewControllerAfter viewController: UIViewController) -> UIViewController? {
			guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
				return nil
			}

			let nextIndex = viewControllerIndex + 1
			let orderedViewControllersCount = orderedViewControllers.count

			// User is on the last view controller and swiped right to loop to
			// the first view controller.
			guard orderedViewControllersCount != nextIndex else {
				return orderedViewControllers.first
			}

			guard orderedViewControllersCount > nextIndex else {
				return nil
			}

			return orderedViewControllers[nextIndex]
	}

	func presentationCount(for pageViewController: UIPageViewController) -> Int {
		return orderedViewControllers.count
	}

	func presentationIndex(for pageViewController: UIPageViewController) -> Int {
		guard let firstViewController = viewControllers?.first,
			let firstViewControllerIndex = orderedViewControllers.index(of: firstViewController) else {
				return 0
		}

		return firstViewControllerIndex
	}
}
