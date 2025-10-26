//
//  PathNodePosition.swift
//  AnxietyTest&Companion
//
//  Helper for calculating node positions along an S-curve path
//

import SwiftUI

struct PathNodePosition {
    let xOffset: CGFloat
    let yPosition: CGFloat
    
    static func positions(count: Int, verticalSpacing: CGFloat = 120, horizontalOffset: CGFloat = 40) -> [PathNodePosition] {
        return (0..<count).map { index in
            let yPos = CGFloat(index) * verticalSpacing
            
            // Alternating left-right pattern: 0 → -offset, 1 → 0, 2 → +offset, 3 → 0, ...
            let xOffset: CGFloat
            switch index % 4 {
            case 0:
                xOffset = -horizontalOffset
            case 1:
                xOffset = 0
            case 2:
                xOffset = horizontalOffset
            case 3:
                xOffset = 0
            default:
                xOffset = 0
            }
            
            return PathNodePosition(xOffset: xOffset, yPosition: yPos)
        }
    }
}
