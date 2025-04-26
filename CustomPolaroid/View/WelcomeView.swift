//
//  WelcomeView.swift
//  CustomPolaroid
//
//  Created by Sofia Sandoval on 4/26/25.
//

import SwiftUI

// MARK: - Welcome View
struct WelcomeView: View {
    let onTakePhoto: () -> Void
    @State private var showTutorial = false
    
    
    var body: some View {
        VStack {
            Spacer()
            Text("Captura y Decora fotos polaroides únicas con un solo clic.")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
            
            Button(action: onTakePhoto) {
                HStack {
                    Image(systemName: "camera.fill")
                        .font(.title2)
                    Text("Capturar Foto")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(15)
            }
            .padding()
           
            .padding(.bottom, 40)
            
        }
    }
}

#Preview {
    WelcomeView {
        
    }
}
