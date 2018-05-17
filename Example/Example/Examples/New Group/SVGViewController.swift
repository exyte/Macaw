import UIKit

open class SVGViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    fileprivate var svgExamples = [
        "shadows",
        "tiger"
    ]
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return svgExamples.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menu_cell")!
        cell.textLabel?.text = svgExamples[indexPath.row].capitalized
        return cell
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = UIStoryboard(name: "Main", bundle: .none).instantiateViewController(withIdentifier: "SVGExampleViewController") as! SVGExampleViewController
        controller.fileName = svgExamples[indexPath.row]
        navigationController?.pushViewController(controller, animated: true)
    }
    
}
