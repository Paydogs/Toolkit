//
//  Color+Toolkit.swift
//  Toolkit
//
//  Created by Andras Olah on 2026. 01. 19..
//

import Foundation

#if canImport(UIKit)
import UIKit

public extension UIColor {
    convenience init?(hex: String) {
        guard let c = hex.rgbaValue else { return nil }
        self.init(red: c.r, green: c.g, blue: c.b, alpha: c.a)
    }
    
    static func randomToolkitColor() -> UIColor? {
        ColorCode.allColors.randomElement()?.uiColor
    }
}

public extension ColorCodeRepresentable {
    var uiColor: UIColor {
        if let resolved = UIColor(hex: hex) { return resolved }
        assertionFailure("Invalid hex in ColorCodeRepresentable: \(hex)")
        return .black
    }
}

#endif

#if canImport(SwiftUI)
import SwiftUI

public extension Color {
    init?(hex: String) {
        guard let c = hex.rgbaValue else { return nil }
        self.init(.sRGB, red: Double(c.r), green: Double(c.g), blue: Double(c.b), opacity: Double(c.a))
    }
    
    static func randomToolkitColor() -> Color? {
        ColorCode.allColors.randomElement()?.color
    }
}

public extension ColorCodeRepresentable {
    var color: Color {
        if let resolved = Color(hex: hex) { return resolved }
        assertionFailure("Invalid hex in ColorCodeRepresentable: \(hex)")
        return .black
    }
}
#endif

public extension String {
    var rgbaValue: (r: Double, g: Double, b: Double, a: Double)? {
        let hex = self.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        let value = UInt64(hex, radix: 16)
        
        guard let value else { return nil }
        
        let r, g, b, a: UInt64
        
        switch hex.count {
        case 3: // RGB (12-bit)
            r = ((value >> 8) & 0xF) * 17
            g = ((value >> 4) & 0xF) * 17
            b = (value & 0xF) * 17
            a = 255
            
        case 6: // RRGGBB
            r = (value >> 16) & 0xFF
            g = (value >> 8) & 0xFF
            b = value & 0xFF
            a = 255
            
        case 8: // RRGGBBAA
            r = (value >> 24) & 0xFF
            g = (value >> 16) & 0xFF
            b = (value >> 8) & 0xFF
            a = value & 0xFF
            
        default:
            return nil
        }
        
        return (Double(r)/255, Double(g)/255, Double(b)/255, Double(a)/255)
    }
}

public protocol ColorCodeRepresentable: Hashable {
    var hex: String { get }
    var caseName: String { get }
    static var categoryName: String { get }
}

public struct ColorCode {
    public enum Red: String, CaseIterable, ColorCodeRepresentable {
        public static let categoryName = "Red"
        case coral = "#FE6F5E"
        case pink = "#FB607F"
        case burgundy = "#800020"
        case red = "#FF0800"
        case blood = "#8B0000"
        case fuchsia = "#FF004F"
    }
    
    public enum Brown: String, CaseIterable, ColorCodeRepresentable {
        public static let categoryName = "Brown"
        case beige = "#F5F5DC"
        case coffee = "#3D2B1F"
        case chestnut = "#CC7F3B"
        case brown = "#7B3F00"
        case bronze = "#CD7F32"
        case bone = "#E3DAC9"
    }
    
    public enum Yellow: String, CaseIterable, ColorCodeRepresentable {
        public static let categoryName = "Yellow"
        case gold = "#FFBF00"
        case lemon = "#FDEE00"
        case yellow = "#FFEF00"
        case honey = "#E6A817"
        case clay = "#E0AB76"
        case mustard = "#FFDB58"
    }
    
    public enum Green: String, CaseIterable, ColorCodeRepresentable {
        public static let categoryName = "Green"
        case moss = "#568203"
        case forest = "#004225"
        case laser = "#3FFF00"
        case malachite = "#0BDA51"
        case green = "#008000"
        case olive = "#808000"
    }
    
    public enum Blue: String, CaseIterable, ColorCodeRepresentable {
        public static let categoryName = "Blue"
        case navy = "#003262"
        case ocean = "#2072AF"
        case blue = "#0000FF"
        case sky = "#1E90FF"
        case marine = "#0070BB"
        case pale = "#B9D9EB"
    }
    
    public enum Gray: String, CaseIterable, ColorCodeRepresentable {
        public static let categoryName = "Gray"
        case platinum = "#F2F3F4"
        case silver = "#C0C0C0"
        case steel = "#91A3B0"
        case gray = "#777777"
        case graphite = "#343434"
        case ash = "#B2BEB5"
    }
    
    public enum Other: String, CaseIterable, ColorCodeRepresentable {
        public static let categoryName = "Other"
        case lavender = "#9966CC"
        case magenta = "#BF00FF"
        case aquamarine = "#7FFFD4"
        case aqua = "#B2FFFF"
        case snow = "#F7F7F7"
        case indigo = "#32127A"
    }
    
    public static var allColors: [any ColorCodeRepresentable] {
        var result: [any ColorCodeRepresentable] = []
        result.append(contentsOf: Red.allCases)
        result.append(contentsOf: Brown.allCases)
        result.append(contentsOf: Yellow.allCases)
        result.append(contentsOf: Green.allCases)
        result.append(contentsOf: Blue.allCases)
        result.append(contentsOf: Gray.allCases)
        result.append(contentsOf: Other.allCases)
        return result
    }
}

extension ColorCodeRepresentable where Self: RawRepresentable, RawValue == String {
    public var hex: String { rawValue }
    public var caseName: String { "\(Self.categoryName).\(String(describing: self))" }
}
