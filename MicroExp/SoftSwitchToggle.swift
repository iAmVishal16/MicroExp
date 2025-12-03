//
//  SoftSwitchToggle.swift
//  MicroExp
//
//  Created by Vishal Paliwal on 03/12/25.
//

import SwiftUI

struct SoftSwitchToggleStyle: ToggleStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        SoftSwitch(configuration: configuration)
    }
    
    private struct SoftSwitch: View {
        let configuration: Configuration
        
        @GestureState private var isPressed: Bool = false
        
        var body: some View {
            let pressGesture = DragGesture(minimumDistance: 0)
                .updating($isPressed) { _, state, _ in
                    state = true
                }
                .onEnded { _ in
                    withAnimation(.interactiveSpring(response: 0.35,
                                                     dampingFraction: 0.7,
                                                     blendDuration: 0.2)) {
                        configuration.isOn.toggle()
                    }
                }
            
            return HStack {
                configuration.label
                
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.black)
                        .frame(width: 72, height: 40)
                        .scaleEffect(x: isPressed ? 0.97 : 1.0,
                                     y: isPressed ? 0.94 : 1.0,
                                     anchor: configuration.isOn ? .trailing : .leading)
                        .shadow(color: .black.opacity(0.35),
                                radius: 6,
                                x: 0,
                                y: 4)
                        .animation(.easeOut(duration: 0.12), value: isPressed)
                    
                    // Knob
                    Circle()
                        .fill(Color("switchColor"))
                        .frame(width: 34, height: 34)
                        .scaleEffect(x: isPressed ? 1.08 : 1.0,
                                     y: isPressed ? 0.9 : 1.0)
                        .shadow(color: .black.opacity(0.4),
                                radius: 4,
                                x: 0,
                                y: 3)
                        .overlay(
                            Image(systemName: configuration.isOn ? "moon" : "sun.min")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 13, height: 13)
                                .foregroundColor(configuration.isOn ? .yellow : .white)
                        )
                        .offset(x: configuration.isOn ? 14 : -14)
                        .animation(.interactiveSpring(response: 0.35,
                                                      dampingFraction: 0.7,
                                                      blendDuration: 0.2),
                                   value: configuration.isOn)
                }
                .contentShape(Rectangle())
                .gesture(pressGesture)
            }
        }
    }
}


struct SoftSwitchPreviewWrapper: View {
    @State private var isOn: Bool = true
    
    var body: some View {
        ZStack {
            (isOn ? Color.black : Color.white)
                                .ignoresSafeArea()
            
            Toggle(isOn: $isOn) {
                //                    Text("Soft Switch")
                //                        .foregroundColor(isOn ? .black : .white)
            }
            .toggleStyle(SoftSwitchToggleStyle())
            .padding()
        }
    }
}

#Preview {
    SoftSwitchPreviewWrapper()
        .preferredColorScheme(.light)
}


