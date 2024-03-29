//
//  ContentView.swift
//  MicroExp
//
//  Created by Vishal Paliwal on 10/01/24.
//

import SwiftUI

struct MicroButton1: View {
    
    @Binding var isSelected: Bool
    
    var body: some View {
        ZStack {
            ForEach(0..<2) { i in
                ForEach(0..<2) { j in
                    Capsule()
                        .frame(width: isSelected ? 20 : 10.0, height: 10)
                        .rotationEffect(.degrees(j == i ? 45 : -45))
                        .offset(x: 12 * CGFloat(i),y: 12 * CGFloat(j))
                }
            }
        }
        .offset(x: -5, y: -5)
        .rotationEffect(isSelected ? .degrees(0) : .degrees(90), anchor: .center)
    }
}


#Preview {
    MicroButton1(isSelected: .constant(false))
        .preferredColorScheme(.dark)
}
