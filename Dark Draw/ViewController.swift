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
    
    let drawing = PKDrawing()

    override func viewDidLoad() {
        super.viewDidLoad()
        canvasView.drawing = drawing
        canvasView.delegate = self
        view.backgroundColor = .systemBackground
        view.addSubview(canvasView)

        // Add navigation bar with toggle button
        let toggleButton = UIBarButtonItem(image: UIImage(systemName: "pencil.tip"), style: .plain, target: self, action: #selector(toggleToolPicker))
        
    
        
        navigationItem.rightBarButtonItem = toggleButton
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
        navigationItem.rightBarButtonItem?.title = toolPickerShows ? "Hide tool picker" : "Show tool picker"
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

