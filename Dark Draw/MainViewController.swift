import UIKit
import CoreData

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            fetchCanvases()
        }
    var collectionView: UICollectionView!
    var canvases: [CanvasModel] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Dark Draw"
        view.backgroundColor = .systemBackground
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 160, height: 180)
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CanvasCell.self, forCellWithReuseIdentifier: "CanvasCell")
        view.addSubview(collectionView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCanvas))
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        collectionView.addGestureRecognizer(longPress)
        fetchCanvases()
    }
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        let point = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: point) else { return }
        let canvas = canvases[indexPath.item]
        let alert = UIAlertController(title: "Canvas Options", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Rename", style: .default) { [weak self] _ in
            self?.presentRenameAlert(for: canvas)
        })
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteCanvas(canvas)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let vc = collectionView.window?.rootViewController {
            vc.present(alert, animated: true)
        } else {
            self.present(alert, animated: true)
        }
    }

    private func presentRenameAlert(for canvas: CanvasModel) {
        let alert = UIAlertController(title: "Rename Canvas", message: "Enter new title", preferredStyle: .alert)
        alert.addTextField { $0.text = canvas.title }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Rename", style: .default) { [weak self] _ in
            guard let self = self, let newTitle = alert.textFields?.first?.text, !newTitle.isEmpty else { return }
            canvas.title = newTitle
            do {
                try self.context.save()
                self.fetchCanvases()
            } catch {
                print("Failed to rename canvas: \(error)")
            }
        })
        present(alert, animated: true)
    }

    private func deleteCanvas(_ canvas: CanvasModel) {
        context.delete(canvas)
        do {
            try context.save()
            fetchCanvases()
        } catch {
            print("Failed to delete canvas: \(error)")
        }
    }

    func fetchCanvases() {
        let request: NSFetchRequest<CanvasModel> = CanvasModel.fetchRequest()
        do {
            canvases = try context.fetch(request)
            collectionView.reloadData()
        } catch {
            print("Failed to fetch canvases: \(error)")
        }
    }

    @objc func addCanvas() {
        let alert = UIAlertController(title: "New Canvas", message: "Enter canvas title", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Title" }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            guard let self = self, let title = alert.textFields?.first?.text, !title.isEmpty else { return }
            let canvas = CanvasModel(context: self.context)
            canvas.title = title
            do {
                try self.context.save()
                self.fetchCanvases()
            } catch {
                print("Failed to save canvas: \(error)")
            }
        })
        present(alert, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return canvases.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CanvasCell", for: indexPath) as! CanvasCell
        let canvas = canvases[indexPath.item]
        cell.configure(with: canvas)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let canvas = canvases[indexPath.item]
        let vc = ViewController()
        vc.canvas = canvas
        navigationController?.pushViewController(vc, animated: true)
    }
}
