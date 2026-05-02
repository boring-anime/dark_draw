import UIKit
import CoreData
import PencilKit
import CoreData

class DrawingPickerViewController: UITableViewController {

		// Enable swipe-to-delete
		override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
			if editingStyle == .delete {
				let drawingToDelete = drawings[indexPath.row]
				// Remove from Core Data
				if let context = drawingToDelete.managedObjectContext {
					context.delete(drawingToDelete)
					do {
						try context.save()
					} catch {
						print("Failed to delete drawing: \(error)")
					}
				}
				// Remove from local array and table
				drawings.remove(at: indexPath.row)
				tableView.deleteRows(at: [indexPath], with: .automatic)
			}
		}
	var drawings: [DesignModel] = []
	var onSelect: ((DesignModel) -> Void)?

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return drawings.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "DrawingCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "DrawingCell")
		cell.textLabel?.text = "Drawing #\(indexPath.row + 1)"
		cell.detailTextLabel?.text = drawings[indexPath.row].objectID.uriRepresentation().absoluteString

		// Generate a thumbnail image from PKDrawing
		let drawing = drawings[indexPath.row].drawing
		let bounds = drawing.bounds.isNull ? CGRect(x: 0, y: 0, width: 100, height: 100) : drawing.bounds
		let image = drawing.image(from: bounds, scale: 0.2)
		cell.imageView?.image = image
		cell.imageView?.contentMode = .scaleAspectFit

		// Optionally, resize the imageView for a thumbnail
		let size = CGSize(width: 44, height: 44)
		UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
		image.draw(in: CGRect(origin: .zero, size: size))
		cell.imageView?.image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		onSelect?(drawings[indexPath.row])
		dismiss(animated: true)
	}
}
