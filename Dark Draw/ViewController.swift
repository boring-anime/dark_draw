//
//  ViewController.swift
//  Dark Draw
//
//  Created by Shubham Kumar on 02/05/26.
//


import PencilKit
import UIKit
import CoreData

class ViewController: UIViewController, PKCanvasViewDelegate {
    private let canvasView: PKCanvasView
    private let toolPicker = PKToolPicker()
    private var toolPickerShows: Bool = true
    private var drawing: PKDrawing {
        get { canvasView.drawing }
        set { canvasView.drawing = newValue }
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.canvasView = PKCanvasView()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        self.canvasView = PKCanvasView()
        super.init(coder: coder)
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .clear
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        canvasView.delegate = self
        view.backgroundColor = .systemBackground
        view.addSubview(canvasView)

        let saveButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.down.doc"),
            style: .plain,
            target: self,
            action: #selector(saveDrawingToCoreData)
        )
        let loadButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.up.doc"),
            style: .plain,
            target: self,
            action: #selector(showDrawingPicker)
        )
        let toggleButton = UIBarButtonItem(
            image: UIImage(systemName: "pencil.tip"),
            style: .plain,
            target: self,
            action: #selector(toggleToolPicker)
        )
        let eraseButton = UIBarButtonItem(
            image: UIImage(systemName: "trash.fill"),
            style: .plain,
            target: self,
            action: #selector(eraseAll)
        )
        navigationItem.rightBarButtonItems = [eraseButton, toggleButton]
        navigationItem.leftBarButtonItems = [saveButton, loadButton]
        navigationItem.title = "Drawing"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        canvasView.frame = view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateToolPicker()
    }

    @objc private func toggleToolPicker() {
        toolPickerShows.toggle()
        updateToolPicker()
    }

    @objc private func eraseAll() {
        drawing = PKDrawing()
    }


    @objc private func saveDrawingToCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let design = DesignModel(context: context)
        design.drawing = canvasView.drawing
        do {
            try context.save()
            print("Drawing saved to Core Data.")
        } catch {
            print("Failed to save drawing: \(error)")
        }
    }


    @objc private func showDrawingPicker() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<DesignModel> = DesignModel.fetchRequest()
        do {
            let results = try context.fetch(fetchRequest)
            let picker = DrawingPickerViewController()
            picker.drawings = results
            picker.onSelect = { [weak self] design in
                self?.canvasView.drawing = design.drawing
                print("Drawing loaded from Core Data.")
            }
            let nav = UINavigationController(rootViewController: picker)
            picker.title = "Select Drawing"
            present(nav, animated: true)
        } catch {
            print("Failed to load drawings: \(error)")
        }
    }

    private func updateToolPicker() {
        toolPicker.setVisible(toolPickerShows, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        if toolPickerShows {
            canvasView.becomeFirstResponder()
        } else {
            canvasView.resignFirstResponder()
        }
    }
    
//    Canvas
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        // Drawing state is always in sync with canvasView.drawing
        // You can add additional logic here if you want to observe changes
        print("Drawing did change")
    }
    
    func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
        print("Did begin using tool")
    }
    
    func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
        print("Did end using tool")
    }
    
    func canvasViewDidFinishRendering(_ canvasView: PKCanvasView) {
        print("Did finish rendering")
    }
}

