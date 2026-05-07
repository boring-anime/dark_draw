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
    // Store last scroll/zoom state
    private var lastContentOffset: CGPoint?
    private var lastZoomScale: CGFloat?
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
        navigationItem.leftBarButtonItems = [backButton]

        
        // Set navigation title to canvas title if available
        if let canvas = canvas {
            navigationItem.title = canvas.title
            // Load last drawing if exists
            if let lastDesign = canvas.drawingsArray.last {
                canvasView.drawing = lastDesign.drawing
            }
            // Restore last scroll/zoom state if available
            if let offsetData = canvas.value(forKey: "lastContentOffset") as? Data,
               let nsValue = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSValue.self, from: offsetData) {
                lastContentOffset = nsValue.cgPointValue
            }
            if let zoom = canvas.value(forKey: "lastZoomScale") as? NSNumber {
                lastZoomScale = CGFloat(truncating: zoom)
            }
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Restore zoom and offset before view is visible to avoid lag
        if let zoom = lastZoomScale, let offset = lastContentOffset {
            // Set both in same async block to ensure layout is ready
            DispatchQueue.main.async {
                self.canvasView.zoomScale = zoom
                self.canvasView.setContentOffset(offset, animated: false)
            }
        } else if let zoom = lastZoomScale {
            self.canvasView.zoomScale = zoom
        } else if let offset = lastContentOffset {
            self.canvasView.setContentOffset(offset, animated: false)
        }
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
        // Save scroll/zoom state to Core Data before leaving
        if let canvas = canvas {
            let offset = canvasView.contentOffset
            let zoom = canvasView.zoomScale
            let offsetData = try? NSKeyedArchiver.archivedData(withRootObject: offset, requiringSecureCoding: false)
            canvas.setValue(offsetData, forKey: "lastContentOffset")
            canvas.setValue(NSNumber(value: Double(zoom)), forKey: "lastZoomScale")
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                let context = appDelegate.persistentContainer.viewContext
                do { try context.save() } catch { print("Failed to save scroll/zoom: \(error)") }
            }
        }
        Task {
            await generateAndSavePreviewImage()
            navigationController?.popViewController(animated: true)
        }
    }

    private func generateAndSavePreviewImage() async {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        guard let canvas = canvas else { return }
        // Get the latest drawing (if any)
        guard let design = canvas.drawingsArray.last else { return }
        let size = CGSize(width: 120, height: 120)
        let rect = CGRect(origin: .zero, size: size)
        // Create a Core Graphics context manually
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let cgContext = UIGraphicsGetCurrentContext() else { UIGraphicsEndImageContext(); return }
        UIColor.clear.setFill()
        cgContext.fill(rect)
        // Await the async draw call
        await design.drawing.draw(in: cgContext, frame: rect, from: rect, darkUserInterfaceStyle: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        // Save the preview image to Core Data
        if let image = image, let data = image.pngData() {
            design.setValue(data, forKey: "previewImage")
            do {
                try context.save()
            } catch {
                print("Failed to save preview image: \(error)")
            }
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
        // Save drawing to Core Data on every change
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        guard let canvas = canvas else { return }
        let design = DesignModel(context: context)
        design.drawing = canvasView.drawing
        design.setValue(Date(), forKey: "timestamp")
        let drawings = canvas.mutableSetValue(forKey: "drawings")
        drawings.add(design)
        do {
            try context.save()
        } catch {
            print("Failed to auto-save drawing: \(error)")
        }
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

