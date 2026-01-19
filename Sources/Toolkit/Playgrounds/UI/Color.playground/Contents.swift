import SwiftUI
import Toolkit
import PlaygroundSupport

struct ColorGridView: View {
    let columns = [
        GridItem(.adaptive(minimum: 80), spacing: 12)
    ]
    
    let colors: [any ColorCodeRepresentable] = ColorCode.allColors
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(colors, id: \.hex) { color in
                    VStack(spacing: 6) {
                        Rectangle()
                            .fill(Color(hex: color.hex) ?? .clear)
                            .frame(height: 80)
                            .cornerRadius(8)
                        
                        Text(color.caseName)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
            
            Divider()
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(0..<60) { _ in
                    VStack(spacing: 6) {
                        Rectangle()
                            .fill(Color.randomToolkitColor() ?? .clear)
                            .frame(height: 80)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
        }
    }
}

PlaygroundPage.current.setLiveView(
    ColorGridView()
        .frame(width: 400, height: 1000)
)
