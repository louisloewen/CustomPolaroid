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
    
    // Add Polaroid frame to the image
    func addPolaroidFrame(to image: UIImage) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: image.size.width + 80, height: image.size.height + 150))
        
        let framedImage = renderer.image { context in
            // Draw white background (Polaroid frame)
            UIColor.white.setFill()
            context.fill(CGRect(x: 0, y: 0, width: image.size.width + 80, height: image.size.height + 150))
            
            // Draw the actual photo
            image.draw(in: CGRect(x: 40, y: 40, width: image.size.width, height: image.size.height))
        }
        
        return framedImage
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

