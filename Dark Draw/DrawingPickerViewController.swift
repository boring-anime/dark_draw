import UIKit
import CoreData

class DrawingPickerViewController: UITableViewController {
	var drawings: [DesignModel] = []
	var onSelect: ((DesignModel) -> Void)?

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return drawings.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "DrawingCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "DrawingCell")
		cell.textLabel?.text = "Drawing #\(indexPath.row + 1)"
		cell.detailTextLabel?.text = drawings[indexPath.row].objectID.uriRepresentation().absoluteString
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		onSelect?(drawings[indexPath.row])
		dismiss(animated: true)
	}
}
