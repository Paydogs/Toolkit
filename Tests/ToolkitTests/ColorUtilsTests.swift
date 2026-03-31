//
//  ColorUtilsTests.swift
//  Toolkit
//
//  Created by Andras Olah on 2026. 03. 31..
//

import Testing
import Toolkit
import UIKit
import SwiftUI

@Suite("Extensions")
struct ColorUtilsTests {
    // MARK: UIKit tests
    @Test func test_uiKit_initFromHex() async throws {
        // Given
        let givenColorWithAlpha = UIColor.init(hex: "FF000000")
        let givenColorWithoutAlpha = UIColor.init(hex: "00FF00")
        
        // Then
        #expect(givenColorWithAlpha == UIColor(red: 1, green: 0, blue: 0, alpha: 0))
        #expect(givenColorWithoutAlpha == UIColor(red: 0, green: 1, blue: 0, alpha: 1))
    }
 
    @Test func test_uiKit_randomColor() async throws {
        // Given
        let randomColor = ColorCode.allColors.randomElement()?.uiColor
        // Then
        #expect(ColorCode.allColors.contains(where: { color in color.uiColor == randomColor }))
    }
    
    // MARK: SwiftUI tests
    @Test func test_swiftUI_initFromHex() async throws {
        // Given
        let givenColorWithAlpha = Color.init(hex: "FF000000")
        let givenColorWithoutAlpha = Color.init(hex: "00FF00")
        
        // Then
        #expect(givenColorWithAlpha == Color(red: 1, green: 0, blue: 0, opacity: 0))
        #expect(givenColorWithoutAlpha == Color(red: 0, green: 1, blue: 0, opacity: 1))
    }
    
    @Test func test_swiftUI_randomColor() async throws {
        // Given
        let randomColor = ColorCode.allColors.randomElement()?.color
        // Then
        #expect(ColorCode.allColors.contains(where: { color in color.color == randomColor }))
    }

    // MARK: String conversion
    @Test func test_rgbaValueConversion() async throws {
        // Given
        let rgbValue1 = "FF0000"
        let rgbValue2 = "#00FF0000"
        let rgbaValue1 = "0000FF"
        let rgbaValue2 = "#0000FF00"
        
        // When
        let result1 = try #require(rgbValue1.rgbaValue)
        let result2 = try #require(rgbValue2.rgbaValue)
        let result3 = try #require(rgbaValue1.rgbaValue)
        let result4 = try #require(rgbaValue2.rgbaValue)
        
        // Then
        #expect(result1 == (1.0, 0.0, 0.0, 1.0))
        #expect(result2 == (0.0, 1.0, 0.0, 0.0))
        #expect(result3 == (0.0, 0.0, 1.0, 1.0))
        #expect(result4 == (0.0, 0.0, 1.0, 0.0))
    }
}
