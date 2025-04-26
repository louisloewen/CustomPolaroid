//
//  CameraPreparationView.swift
//  CustomPolaroid
//
//  Created by Sofia Sandoval on 4/26/25.
//

import SwiftUI

struct CameraPreparationView: View {
    @Binding var capturedImage: UIImage?
    @Binding var isShown: Bool
    @State private var showCamera = false
    
    var body: some View {
        NavigationStack{
            VStack {
                ZStack {
                    // Background image
                    Image("Background")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                    
                    VStack {
                        Spacer()
                        
                        // Cancel button
                        Button(action: {
                            isShown = false
                        }) {
                            Text("Cancelar")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white.opacity(0.2))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding()
                    }
                    
                }
                .navigationTitle("Captura tu imagen")
                
            }
            .onAppear {
                // Automatically show camera after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showCamera = true
                }
            }
            .sheet(isPresented: $showCamera, onDismiss: {
                isShown = false
                
            }) {
                CameraView(capturedImage: $capturedImage, isShown: $showCamera)
            }
        }
    }
}
