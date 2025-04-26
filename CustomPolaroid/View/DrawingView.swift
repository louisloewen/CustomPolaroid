//
//  DrawingView.swift
//  CustomPolaroid
//
//  Created by Sofia Sandoval on 25/04/25.
//

import SwiftUI
import UIKit
import AVFoundation
import PencilKit
import MessageUI

// MARK: - Modern Drawing View
struct DrawingView: View {
    let image: UIImage
    @Binding var isShown: Bool
    @Binding var finalImage: UIImage?
    @State private var viewController: DrawingViewController?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Add the background image
                Image("Background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    // Drawing area
                    DrawingCanvas(
                        image: image,
                        isShown: $isShown,
                        finalImage: $finalImage,
                        viewController: $viewController
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .padding()
                    
                    Spacer()
                }
                .navigationTitle("Personaliza tu Polaroid")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            viewController?.captureDrawing()
                        }) {
                            Text("Listo")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(Color.accentColor.gradient)
                                        .shadow(color: Color.accentColor.opacity(0.3), radius: 5, x: 0, y: 3)
                                )
                        }
                    }
                }
            }
        }
    }
}


// MARK: - Drawing Canvas
struct DrawingCanvas: UIViewControllerRepresentable {
    let image: UIImage
    @Binding var isShown: Bool
    @Binding var finalImage: UIImage?
    @Binding var viewController: DrawingViewController?
    
    func makeUIViewController(context: Context) -> DrawingViewController {
        let controller = DrawingViewController()
        controller.startingImage = image
        controller.delegate = context.coordinator
      
        DispatchQueue.main.async {
            viewController = controller
        }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: DrawingViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, DrawingViewControllerDelegate {
        let parent: DrawingCanvas
        
        init(_ parent: DrawingCanvas) {
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

// MARK: - Modern Drawing View Controller
class DrawingViewController: UIViewController, PKCanvasViewDelegate, PKToolPickerObserver {
    weak var delegate: DrawingViewControllerDelegate?
    var startingImage: UIImage?
    private var canvasView: PKCanvasView!
    private var imageView: UIImageView!
    private var toolPicker: PKToolPicker?
    private var isProcessing = false
    private var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        // Container view with modern styling
        containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        view.addSubview(containerView)
        
        // Setup image view
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = startingImage
        containerView.addSubview(imageView)
        
        // Setup canvas view
        canvasView = PKCanvasView()
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.delegate = self
        canvasView.drawingPolicy = .anyInput
        canvasView.maximumZoomScale = 1.0
        canvasView.minimumZoomScale = 1.0
        canvasView.isScrollEnabled = false
        
        // Keep default tool configuration
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 5)
        containerView.addSubview(canvasView)
        
        setupToolPicker()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Modern layout without hardcoded values
        let safeArea = view.safeAreaInsets
        let padding: CGFloat = 20
        let availableWidth = view.bounds.width - (padding * 2)
        let availableHeight = view.bounds.height - safeArea.top - safeArea.bottom - (padding * 2)
        
        // Calculate aspect fit dimensions
        if let image = startingImage {
            let imageAspect = image.size.width / image.size.height
            let containerAspect = availableWidth / availableHeight
            
            var containerWidth: CGFloat
            var containerHeight: CGFloat
            
            if imageAspect > containerAspect {
                containerWidth = availableWidth
                containerHeight = containerWidth / imageAspect
            } else {
                containerHeight = availableHeight
                containerWidth = containerHeight * imageAspect
            }
            
            // Center the container
            let x = (view.bounds.width - containerWidth) / 2
            let y = (view.bounds.height - containerHeight) / 2
            
            containerView.frame = CGRect(x: x, y: y, width: containerWidth, height: containerHeight)
            imageView.frame = containerView.bounds
            canvasView.frame = containerView.bounds
        }
    }
    
    private func setupToolPicker() {
        toolPicker = PKToolPicker()
        toolPicker?.addObserver(canvasView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        toolPicker?.setVisible(true, forFirstResponder: canvasView)
        canvasView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        toolPicker?.setVisible(false, forFirstResponder: canvasView)
        canvasView.resignFirstResponder()
    }
    
    // Public function to trigger capture
    func captureDrawing() {
        guard !isProcessing else { return }
        isProcessing = true
        
        // Hide tool picker before capturing
        toolPicker?.setVisible(false, forFirstResponder: canvasView)
        canvasView.resignFirstResponder()
        
        // Wait a moment for UI to update
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.captureContainerView()
        }
    }
    
    private func captureContainerView() {
        let renderer = UIGraphicsImageRenderer(bounds: containerView.bounds)
        
        let capturedImage = renderer.image { context in
            containerView.drawHierarchy(in: containerView.bounds, afterScreenUpdates: true)
        }
        
        DispatchQueue.main.async {
            self.delegate?.drawingViewController(self, didFinishDrawing: capturedImage)
            self.isProcessing = false
        }
    }
}
