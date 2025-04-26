//
//  CapturedImageView.swift
//  CustomPolaroid
//
//  Created by Sofia Sandoval on 4/26/25.
//

import SwiftUI

// MARK: - Captured Image View
struct CapturedImageView: View {
    let image: UIImage
    let onEdit: () -> Void
    let onRetake: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            // Image preview with frame
            ZStack {
                Rectangle()
                    .fill(Color.secondary.opacity(0.3))
                    .shadow(radius: 5)
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding(8)
            }
            .aspectRatio(3/4, contentMode: .fit)
            .padding(.horizontal, 50)
            .padding(.top, 40)
            
       
           
            // Action buttons
            VStack {
                Button(action: onEdit) {
                    HStack {
                        Image(systemName: "paintbrush.fill")
                        Text("Agregar Marco Polaroid y Customizar")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                Button(action: onRetake) {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Capturar foto de nuevo")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 70)
        }
        .navigationTitle("Confirma la foto capturada")
    }
}
