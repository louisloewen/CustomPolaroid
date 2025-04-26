//
//  FinalImageView.swift
//  CustomPolaroid
//
//  Created by Sofia Sandoval on 4/26/25.
//

import SwiftUI

// MARK: - Final Image View
struct FinalImageView: View {
    let image: UIImage
    let onNewPhoto: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            // Final polaroid preview
            Image(uiImage: image)
                .resizable()
                .shadow(radius: 10)
                
                .scaledToFit()
                .frame(maxWidth: 600)
                .padding()
            

            
            // Action buttons
            HStack(spacing: 15) {
                ShareLink(item: Image(uiImage: image),
                         preview: SharePreview("Tu Foto de Recuedo Dia de la Familia", image: Image(uiImage: image))) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Exportar")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                Button(action: onNewPhoto) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Nueva Foto")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
        }
        .navigationTitle("¡Tu Polaroid esta lista!")
    }
}

