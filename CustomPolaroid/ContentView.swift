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
    @State private var showCameraPrep = false
    @State private var showEditor = false
    @State private var finalImage: UIImage?
    
    var body: some View {
        if showEditor, let image = capturedImage {
            DrawingView(image: image, isShown: $showEditor, finalImage: $finalImage)
        } else {
            NavigationStack {
                ZStack {
                    // Background logic based on current state
                    backgroundView
                    
                    // Content logic
                    contentView
                }
                .fullScreenCover(isPresented: $showCameraPrep) {
                    CameraPreparationView(capturedImage: $capturedImage, isShown: $showCameraPrep)
                }
            }
        }
    }
    
    private var backgroundView: some View {
        Group {
            if finalImage != nil || capturedImage != nil {
                // For captured or final image views, use the default background
                Image("Background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            } else {
                // For welcome view, use the welcome background
                Image("welcomeBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            }
        }
    }
    
    private var contentView: some View {
        Group {
            if let unwrappedImage = finalImage {
                FinalImageView(image: unwrappedImage,
                             onNewPhoto: {
                                 capturedImage = nil
                                 finalImage = nil
                             })
            } else if let capturedImg = capturedImage {
                CapturedImageView(image: capturedImg,
                                onEdit: {
                                    let framedImage = addPolaroidFrame(to: capturedImg)
                                    capturedImage = framedImage
                                    showEditor = true
                                },
                                onRetake: {
                                    capturedImage = nil
                                })
            } else {
                WelcomeView(onTakePhoto: {
                    showCameraPrep = true
                })
            }
        }
    }
    
    func addPolaroidFrame(to image: UIImage) -> UIImage {
        // Define consistent frame proportions
        let frameWidth: CGFloat = 150   // Side margins
        let topMargin: CGFloat = 200    // Top margin
        let bottomMargin: CGFloat = 600 // Bottom margin for writing
        
        // Calculate final size maintaining original image proportions
        let frameSize = CGSize(
            width: image.size.width + (frameWidth * 2),
            height: image.size.height + topMargin + bottomMargin
        )
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale  // Use original image scale
        format.opaque = true
        
        let renderer = UIGraphicsImageRenderer(size: frameSize, format: format)
        
        return renderer.image { context in
            // Draw white background
            UIColor.white.setFill()
            let framePath = UIBezierPath(
                roundedRect: CGRect(origin: .zero, size: frameSize),
                cornerRadius: 15
            )
            framePath.fill()
            
            // Add subtle shadow
            UIColor(white: 0.9, alpha: 1.0).setFill()
            let shadowRect = CGRect(
                x: frameWidth - 5,
                y: topMargin - 5,
                width: image.size.width + 10,
                height: image.size.height + 10
            )
            let shadowPath = UIBezierPath(rect: shadowRect)
            shadowPath.fill()
            
            // Draw the photo
            let photoRect = CGRect(
                x: frameWidth,
                y: topMargin,
                width: image.size.width,
                height: image.size.height
            )
            
            image.draw(in: photoRect)
            
            // Add border
            UIColor.lightGray.setStroke()
            let borderPath = UIBezierPath(rect: photoRect)
            borderPath.lineWidth = 1
            borderPath.stroke()
        }
    }
}

#Preview {
    ContentView()
}
