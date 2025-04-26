//
//  CapturedImageView.swift
//  CustomPolaroid
//
//  Created by Sofia Sandoval on 4/26/25.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

// MARK: - Captured Image View
struct CapturedImageView: View {
    let image: UIImage
    let onEdit: (UIImage) -> Void
    let onRetake: () -> Void
    
    @State private var selectedFilter: FilterType = .none
    @State private var filteredImage: UIImage?
    @State private var isProcessing: Bool = false
    
    private let filterManager = FilterManager()
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Image preview with frame
            imagePreviewSection
            
            // Filter selector
            filterSelectorSection
            
            // Action buttons
            actionButtonsSection
        }
        .navigationTitle("Confirma la foto capturada")
        .onAppear {
            filteredImage = image
        }
    }
    
    // Breaking down the view into simpler sections
    private var imagePreviewSection: some View {
        VStack {
            
            if isProcessing {
                ProgressView()
                    .scaleEffect(1.5)
            } else {
                Image(uiImage: filteredImage ?? image)
                    .resizable()
                    .scaledToFit()
                    .padding(8)
            }
        }
        .aspectRatio(3/4, contentMode: .fit)
        .padding(.horizontal, 50)
        .shadow(radius: 10)
        .padding(.top, 40)
    }
    
    private var filterSelectorSection: some View {
        VStack{
            Text("Selecciona un filtro")
                .foregroundColor(.white)
                .fontWeight(.bold)
              
            
            HStack(spacing: 15) {
                ForEach(FilterType.allCases, id: \.self) { filter in
                    FilterButton(
                        filter: filter,
                        isSelected: selectedFilter == filter,
                        originalImage: image,
                        filterManager: filterManager
                    ) {
                        applySelectedFilter(filter)
                    }
                }
            }
        }
        .padding()
        
        .background(Color.secondary.opacity(0.2))
        .cornerRadius(12)
            
      
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            Button(action: {
                onEdit(filteredImage ?? image)
            }) {
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
    
    private func applySelectedFilter(_ filter: FilterType) {
        isProcessing = true
        selectedFilter = filter
        
        DispatchQueue.global(qos: .userInitiated).async {
            let processed = filterManager.applyFilter(to: image, filter: filter)
            
            DispatchQueue.main.async {
                filteredImage = processed
                isProcessing = false
            }
        }
    }
}

// MARK: - Filter Type Enum
enum FilterType: String, CaseIterable {
    case none = "Original"
    case sepia = "Dorado"
    case noir = "Nocturno"
    case vintage = "Polaroid"
    case warm = "Soleado"
    case cool = "Congelado"
    case monochrome = "Nublado"
    case fade = "Nieve"
    

}

// MARK: - Filter Button
struct FilterButton: View {
    let filter: FilterType
    let isSelected: Bool
    let originalImage: UIImage
    let filterManager: FilterManager
    let action: () -> Void
    
    @State private var thumbnailImage: UIImage?
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                if let thumbnailImage = thumbnailImage {
                    Image(uiImage: thumbnailImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 3)
                        )
                }
                Text(filter.rawValue)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(isSelected ? .accentColor : .white)
                    .multilineTextAlignment(.center)
                    .frame(width: 80)
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .onAppear {
            generateThumbnail()
        }
    }
    
    private func generateThumbnail() {
        DispatchQueue.global(qos: .userInitiated).async {
            let thumbnail = filterManager.createThumbnail(from: originalImage)
            let filteredThumbnail = filterManager.applyFilter(to: thumbnail, filter: filter)
            DispatchQueue.main.async {
                self.thumbnailImage = filteredThumbnail
            }
        }
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Filter Manager
class FilterManager {
    private let context = CIContext()
    
    func applyFilter(to image: UIImage, filter: FilterType) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        let ciImage = CIImage(cgImage: cgImage)
        
        let filteredImage: CIImage
        
        switch filter {
        case .none:
            return image
            
        case .sepia:
            let sepiaFilter = CIFilter.sepiaTone()
            sepiaFilter.inputImage = ciImage
            sepiaFilter.intensity = 0.7
            filteredImage = sepiaFilter.outputImage ?? ciImage
            
        case .noir:
            let noirFilter = CIFilter.photoEffectNoir()
            noirFilter.inputImage = ciImage
            filteredImage = noirFilter.outputImage ?? ciImage
            
        case .vintage:
            let vintageFilter = CIFilter.photoEffectInstant()
            vintageFilter.inputImage = ciImage
            filteredImage = vintageFilter.outputImage ?? ciImage
            
        case .warm:
            let warmFilter = CIFilter.temperatureAndTint()
            warmFilter.inputImage = ciImage
            warmFilter.neutral = CIVector(x: 6500, y: 0)
            warmFilter.targetNeutral = CIVector(x: 4800, y: 0)
            filteredImage = warmFilter.outputImage ?? ciImage
            
        case .cool:
            let coolFilter = CIFilter.temperatureAndTint()
            coolFilter.inputImage = ciImage
            coolFilter.neutral = CIVector(x: 6500, y: 0)
            coolFilter.targetNeutral = CIVector(x: 8500, y: 0)
            filteredImage = coolFilter.outputImage ?? ciImage
            
        case .monochrome:
            let monoFilter = CIFilter.colorMonochrome()
            monoFilter.inputImage = ciImage
            monoFilter.color = CIColor(red: 0.8, green: 0.8, blue: 0.8)
            monoFilter.intensity = 1.0
            filteredImage = monoFilter.outputImage ?? ciImage
            
        case .fade:
            let fadeFilter = CIFilter.photoEffectFade()
            fadeFilter.inputImage = ciImage
            filteredImage = fadeFilter.outputImage ?? ciImage
        }
        
        guard let outputCGImage = context.createCGImage(filteredImage, from: filteredImage.extent) else {
            return image
        }
        
        return UIImage(cgImage: outputCGImage, scale: image.scale, orientation: image.imageOrientation)
    }
    
    func createThumbnail(from image: UIImage, targetSize: CGSize = CGSize(width: 80, height: 80)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
