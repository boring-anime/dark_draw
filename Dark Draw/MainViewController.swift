import UIKit
import CoreData

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var collectionView: UICollectionView!
    var canvases: [CanvasModel] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Canvases"
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
        fetchCanvases()
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

class CanvasCell: UICollectionViewCell {
    let titleLabel = UILabel()
    let previewView = UIImageView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        previewView.contentMode = .scaleAspectFit
        previewView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(previewView)
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            previewView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            previewView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            previewView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            previewView.heightAnchor.constraint(equalToConstant: 120),
            titleLabel.topAnchor.constraint(equalTo: previewView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    func configure(with canvas: CanvasModel) {
        titleLabel.text = canvas.title
        // PKDrawing to UIImage preview is disabled due to async API change
        previewView.image = UIImage(systemName: "scribble")
    }
}
