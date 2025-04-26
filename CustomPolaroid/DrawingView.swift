//
//  DrawingView.swift
//  CustomPolaroid
//
//  Created by Louis Loewen on 25/04/25.
//

import SwiftUI
import UIKit
import AVFoundation
import PencilKit
import MessageUI

// MARK: - Drawing View with PencilKit
struct DrawingView: UIViewControllerRepresentable {
    let image: UIImage
    @Binding var isShown: Bool
    @Binding var finalImage: UIImage?
    
    func makeUIViewController(context: Context) -> DrawingViewController {
        let controller = DrawingViewController()
        controller.startingImage = image
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: DrawingViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, DrawingViewControllerDelegate {
        let parent: DrawingView
        
        init(_ parent: DrawingView) {
            self.parent = parent
        }
        
        func drawingViewController(_ viewController: DrawingViewController, didFinishDrawing image: UIImage) {
            parent.finalImage = image
            parent.isShown = false
        }
    }
}

// Protocol for DrawingViewController delegate
protocol DrawingViewControllerDelegate: AnyObject {
    func drawingViewController(_ viewController: DrawingViewController, didFinishDrawing image: UIImage)
}

// UIViewController that contains PencilKit canvas
class DrawingViewController: UIViewController {
    weak var delegate: DrawingViewControllerDelegate?
    var startingImage: UIImage?
    private var canvasView: PKCanvasView!
    private var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup image view
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.image = startingImage
        view.addSubview(imageView)
        
        // Setup canvas view
        canvasView = PKCanvasView(frame: view.bounds)
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 5)
        view.addSubview(canvasView)
        
        // Setup toolbar
        let toolPicker = PKToolPicker()
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
        
        // Add done button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneDrawing))
        
        // If this view controller is presented modally without a navigation controller
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(doneDrawing), for: .touchUpInside)
        doneButton.frame = CGRect(x: view.bounds.width - 100, y: 50, width: 80, height: 40)
        view.addSubview(doneButton)
    }
    
    @objc func doneDrawing() {
        // Combine image and drawing into one image
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        let finalImage = renderer.image { ctx in
            imageView.drawHierarchy(in: imageView.bounds, afterScreenUpdates: true)
            canvasView.drawHierarchy(in: canvasView.bounds, afterScreenUpdates: true)
        }
        
        delegate?.drawingViewController(self, didFinishDrawing: finalImage)
        dismiss(animated: true)
    }
}

