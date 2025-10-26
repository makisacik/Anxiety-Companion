//
//  CalmJourneyPathShape.swift
//  AnxietyTest&Companion
//
//  Curved connecting path between journey nodes
//

import SwiftUI

struct CalmJourneyPathShape: Shape {
    let nodePositions: [PathNodePosition]
    let nodeRadius: CGFloat
    
    init(nodePositions: [PathNodePosition], nodeRadius: CGFloat = 35) {
        self.nodePositions = nodePositions
        self.nodeRadius = nodeRadius
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        guard nodePositions.count > 1 else { return path }
        
        for i in 0..<nodePositions.count - 1 {
            let currentPos = nodePositions[i]
            let nextPos = nodePositions[i + 1]
            
            // Calculate actual positions (accounting for center of rect)
            let startX = rect.midX + currentPos.xOffset
            let startY = currentPos.yPosition + nodeRadius
            let endX = rect.midX + nextPos.xOffset
            let endY = nextPos.yPosition + nodeRadius
            
            // Move to start of segment
            if i == 0 {
                path.move(to: CGPoint(x: startX, y: startY))
            }
            
            // Draw smooth curve using quadratic bezier
            let controlPointX = (startX + endX) / 2
            let controlPointY = (startY + endY) / 2
            
            path.addQuadCurve(
                to: CGPoint(x: endX, y: endY),
                control: CGPoint(x: controlPointX, y: controlPointY)
            )
        }
        
        return path
    }
}
