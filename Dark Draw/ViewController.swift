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
    let canvasView: PKCanvasView
    var canvas: CanvasModel? // The current canvas
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
        canvasView.frame = view.bounds
        view.addSubview(canvasView)

        // Enable zooming
        canvasView.minimumZoomScale = 0.2
        canvasView.maximumZoomScale = 4.0
        canvasView.zoomScale = 1.0
        canvasView.isScrollEnabled = true

        // Infinite canvas using PKCanvasView's built-in scroll/zoom
        let canvasSize = CGSize(width: 5000, height: 5000)
        canvasView.contentSize = canvasSize
        // Center the visible rect on launch
        let centerOffset = CGPoint(
            x: (canvasSize.width - view.bounds.width) / 2,
            y: (canvasSize.height - view.bounds.height) / 2
        )
        canvasView.setContentOffset(centerOffset, animated: false)

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
        // Add a custom back button to return to main page
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backToMainPage))
        navigationItem.leftBarButtonItems = [backButton, saveButton, loadButton]

        
        // Set navigation title to canvas title if available
        if let canvas = canvas {
            navigationItem.title = canvas.title
        } else {
            navigationItem.title = "Drawing"
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        canvasView.frame = view.bounds
        // Keep zoom scale and content offset consistent on rotation/resize
        canvasView.minimumZoomScale = 0.2
        canvasView.maximumZoomScale = 4.0
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

    @objc private func backToMainPage() {
        navigationController?.popViewController(animated: true)
    }


    @objc private func saveDrawingToCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        guard let canvas = canvas else { return }
        let design = DesignModel(context: context)
        design.drawing = canvasView.drawing
        // Optionally add a timestamp property to DesignModel for ordering
        design.setValue(Date(), forKey: "timestamp")
        // Add drawing to canvas
        let drawings = canvas.mutableSetValue(forKey: "drawings")
        drawings.add(design)
        do {
            try context.save()
            print("Drawing saved to Canvas.")
        } catch {
            print("Failed to save drawing: \(error)")
        }
    }


    @objc private func showDrawingPicker() {
        guard let canvas = canvas else { return }
        let drawings = canvas.drawingsArray
        let picker = DrawingPickerViewController()
        picker.drawings = drawings
        picker.onSelect = { [weak self] design in
            self?.canvasView.drawing = design.drawing
            print("Drawing loaded from Canvas.")
        }
        let nav = UINavigationController(rootViewController: picker)
        picker.title = "Select Drawing"
        present(nav, animated: true)
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

