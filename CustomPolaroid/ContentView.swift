//
//  ContentView.swift
//  CustomPolaroid
//
//  Created by Louis Loewen on 25/04/25.
//

import SwiftUI
import UIKit
import AVFoundation
import PencilKit
import MessageUI

// MARK: - Content View
struct ContentView: View {
    @State private var capturedImage: UIImage?
    @State private var showCamera = false
    @State private var showEditor = false
    @State private var finalImage: UIImage?
    @State private var showingExportOptions = false
    
    var body: some View {
        VStack {
            if let unwrappedImage = finalImage {
                Image(uiImage: unwrappedImage)
                    .resizable()
                    .scaledToFit()
                    .padding()
                
                HStack {
                    Button("Export") {
                        showingExportOptions = true
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button("New Photo") {
                        capturedImage = nil
                        finalImage = nil
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            } else if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding()
                
                Button("Add Polaroid Frame & Edit") {
                    let framedImage = addPolaroidFrame(to: image)
                    capturedImage = framedImage
                    showEditor = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            } else {
                Button("Take Photo") {
                    showCamera = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraView(capturedImage: $capturedImage, isShown: $showCamera)
        }
        .sheet(isPresented: $showEditor) {
            if let image = capturedImage {
                DrawingView(image: image, isShown: $showEditor, finalImage: $finalImage)
            }
        }
        .actionSheet(isPresented: $showingExportOptions) {
            ActionSheet(title: Text("Export Options"), buttons: [
                .default(Text("Save to Photos")) { saveToPhotoLibrary() },
                
                .cancel()
            ])
        }
    }
    
    func addPolaroidFrame(to image: UIImage) -> UIImage {
        // Calculate dimensions for a proper Polaroid look with more frame space
        let sideFrameWidth: CGFloat = 150      // Increased side margins
        let topFrameWidth: CGFloat = 200       // Top margin
        let bottomMargin: CGFloat = 600       // Much larger bottom margin for writing
        
        let frameSize = CGSize(
            width: image.size.width + (sideFrameWidth * 2),
            height: image.size.height + topFrameWidth + bottomMargin
        )
        
        let renderer = UIGraphicsImageRenderer(size: frameSize)
        
        return renderer.image { context in
            // Draw main white background with slight off-white color for more realism
            UIColor(white: 0.97, alpha: 1.0).setFill()
            
            // Create rounded rectangle for the frame
            let framePath = UIBezierPath(
                roundedRect: CGRect(origin: .zero, size: frameSize),
                cornerRadius: 15
            )
            framePath.fill()
            
            // Add subtle shadow inside the frame
            context.cgContext.setShadow(
                offset: CGSize(width: 0, height: 0),
                blur: 5,
                color: UIColor(white: 0.8, alpha: 0.5).cgColor
            )
            
            // Draw the photo with a slight inset
            let photoRect = CGRect(
                x: sideFrameWidth,
                y: topFrameWidth,
                width: image.size.width,
                height: image.size.height
            )
            
            // Reset shadow before drawing the image
            context.cgContext.setShadow(offset: .zero, blur: 0, color: nil)
            image.draw(in: photoRect)
            
            // Add a subtle border around the photo
            UIColor(white: 0.8, alpha: 0.5).setStroke()
            UIBezierPath(rect: photoRect).stroke()
            
            // Optional: Add subtle texture or grain to the frame
            addSubtleTextureToFrame(context: context.cgContext, rect: CGRect(origin: .zero, size: frameSize))
        }
    }

    // Helper function to add subtle texture to the Polaroid frame
    private func addSubtleTextureToFrame(context: CGContext, rect: CGRect) {
        // Save the current graphics state
        context.saveGState()
        
        // Create a clipping path to ensure texture only applies to the frame
        let framePath = UIBezierPath(roundedRect: rect, cornerRadius: 15)
        framePath.addClip()
        
        // Set a very subtle gray color
        UIColor(white: 0, alpha: 0.02).setFill()
        
        // Add random "specks" for texture
        let numberOfSpecks = Int(rect.width * rect.height / 300)
        for _ in 0..<numberOfSpecks {
            let speckSize = CGFloat.random(in: 0.5...1.5)
            let x = CGFloat.random(in: rect.minX...rect.maxX)
            let y = CGFloat.random(in: rect.minY...rect.maxY)
            
            let speckRect = CGRect(
                x: x - speckSize/2,
                y: y - speckSize/2,
                width: speckSize,
                height: speckSize
            )
            
            UIBezierPath(ovalIn: speckRect).fill()
        }
        
        // Restore the graphics state
        context.restoreGState()
    }
    
    // Save image to photo library
    func saveToPhotoLibrary() {
        guard let image = finalImage else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
}


#Preview {
    ContentView()
}

