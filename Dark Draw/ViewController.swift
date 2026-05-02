//
//  ViewController.swift
//  Dark Draw
//
//  Created by Shubham Kumar on 02/05/26.
//


import PencilKit
import UIKit

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
            action: #selector(saveDrawing)
        )
        
        // Add navigation bar with toggle button
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
        navigationItem.leftBarButtonItem = saveButton
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

    @objc private func saveDrawing() {
            drawing.saveToPhotoLibrary()
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

