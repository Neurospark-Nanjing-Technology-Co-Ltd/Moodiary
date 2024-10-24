//
//  CloudShape.swift
//  Moodiary
//
//  Created by YI HE on 2024/10/24.
//
import SwiftUI

struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        path.move(to: CGPoint(x: 0.5*width, y: 0.4*height))
        path.addCurve(to: CGPoint(x: 0.9*width, y: 0.6*height),
                      control1: CGPoint(x: 0.7*width, y: 0.2*height),
                      control2: CGPoint(x: width, y: 0.4*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: 0.8*height),
                      control1: CGPoint(x: 0.8*width, y: 0.8*height),
                      control2: CGPoint(x: 0.7*width, y: height))
        path.addCurve(to: CGPoint(x: 0.1*width, y: 0.6*height),
                      control1: CGPoint(x: 0.3*width, y: height),
                      control2: CGPoint(x: 0, y: 0.8*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: 0.4*height),
                      control1: CGPoint(x: 0.2*width, y: 0.4*height),
                      control2: CGPoint(x: 0.3*width, y: 0.2*height))
        
        return path
    }
}

struct CloudView: View {
    @State private var phase: CGFloat = 0
    
    var body: some View {
        ZStack {
            ForEach(0..<3) { i in
                CloudShape()
                    .fill(Color.blue.opacity(0.3 - Double(i) * 0.1))
                    .scaleEffect(1.0 + CGFloat(i) * 0.1)
                    .offset(x: sin(phase + Double(i) * .pi * 2/3) * 10,
                            y: cos(phase + Double(i) * .pi * 2/3) * 10)
                    .animation(
                        Animation.easeInOut(duration: 4)
                            .repeatForever(autoreverses: false)
                            .delay(Double(i) * 1.3),
                        value: phase
                    )
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                phase += 2 * .pi
            }
        }
    }
}
