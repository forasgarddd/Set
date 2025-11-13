//
//  Diamond.swift
//  Set
//
//  Created by Ivan Devitskyi on 09/11/2025.
//

import SwiftUI

struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let startingPoint = CGPoint(x: rect.maxX, y: center.y)
        path.move(to: startingPoint)
        
        let secondPoint = CGPoint(x: center.x, y: rect.maxY)
        let thirdPoint = CGPoint(x: rect.minX , y: center.y)
        let fourthPoint = CGPoint(x: center.x, y: rect.minY)
        
        path.addLine(to: secondPoint)
        path.addLine(to: thirdPoint)
        path.addLine(to: fourthPoint)
        path.addLine(to: startingPoint)
        
        return path
    }
    
    var body: some View {
        VStack {
            Diamond()
                .fill(.yellow)
        }
    }
}

#Preview {
    Diamond()
}
