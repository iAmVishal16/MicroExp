//
//  SidePanel.swift
//  MicroExp
//
//  Created by Vishal Paliwal on 12/01/24.
//

import SwiftUI

struct SidePanel: View {
    
    @Binding var isSidebarVisible: Bool
    var sideBarWidth = UIScreen.main.bounds.size.width * 0.2
    
    @Binding var toggleTheme: Bool
    
    var body: some View {
            ZStack {
                GeometryReader { _ in
                    EmptyView()
                }
//                .background(.black.opacity(0.6))
                .opacity(isSidebarVisible ? 1 : 0)
                .animation(.easeInOut.delay(0.2), value: isSidebarVisible)
                .onTapGesture {
                    isSidebarVisible.toggle()
                }
                content
            }
            .edgesIgnoringSafeArea(.all)
        }

        var content: some View {
            HStack(alignment: .top) {
                ZStack(alignment: .top) {
                    Color("SidePanelColor")
                    
                    SidePanelView(toggleSwitch: $toggleTheme)
                }
                .frame(width: sideBarWidth)
                .offset(x: isSidebarVisible ? UIScreen.main.bounds.size.width - sideBarWidth : UIScreen.main.bounds.size.width)
                .animation(.default, value: isSidebarVisible)

                Spacer()
            }
            .environment(\.colorScheme, toggleTheme ? .light : .dark)
        }
}

struct MainView: View {
    
    @State private var isPanelVisible = false
    var sideBarWidth = UIScreen.main.bounds.size.width * 0.2
    @State var toggleTheme: Bool = true

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.yellow)
                .offset(x: isPanelVisible ? -sideBarWidth : 0)
                .animation(.default, value: isPanelVisible)
                .edgesIgnoringSafeArea(.all)
            
            SidePanel(isSidebarVisible: $isPanelVisible, toggleTheme: $toggleTheme)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                isPanelVisible.toggle()
            } label: {
                ZStack {
                    MicroButton1(isSelected: $isPanelVisible)
                        .foregroundColor(toggleTheme ? .white : .black)
                    .padding([.top, .trailing], 28)
                }
            }

        }
        .environment(\.colorScheme, toggleTheme ? .light : .dark)
    }
}

struct SidePanelView: View {
    
    @State var selectedIndex = 0
    @State var arrIcons = ["house", "chart.bar" ,"list.bullet.clipboard", "heart", "bell", "person"]
    @Binding var toggleSwitch:Bool

    
    var body: some View {
        ZStack {
            VStack(spacing: 64) {
                
                Spacer()
                
                ForEach(0 ..< arrIcons.count, id: \.self) { idx in
                    let icon = arrIcons[idx]
                    Image(systemName: selectedIndex == idx ? icon + ".fill": icon)
                        .foregroundColor(selectedIndex == idx ? (toggleSwitch ? .white : .black) : .gray.opacity(0.45))
                        .overlay(alignment: .center) {
                            RoundedRectangle(cornerRadius: 8)
                                .frame(width: 48, height: 48)
                                .padding()
                                .foregroundColor(toggleSwitch ? .black.opacity(0.25) : .yellow.opacity(0.15))
                                .opacity(selectedIndex == idx ? 1 : 0)
                                .animation(.spring, value: selectedIndex)
                        }
                        .overlay(alignment: .topTrailing, content: {
                            Circle()
                                .frame(height: 8)
                                .foregroundColor(.pink)
                                .opacity(idx == 4 ? 1 : 0)
                        })
                        .onTapGesture {
                            selectedIndex = idx
                        }
                }
                
//                Spacer()
                
                Toggle(isOn: $toggleSwitch, label: {
                    
                })
                .toggleStyle(ThemeToggleStyle())
                .padding(.bottom, 64)
            }
            .foregroundColor(.white)
        }
        .environment(\.colorScheme, toggleSwitch ? .light : .dark)
    }
}

#Preview {
    MainView()
}

struct ThemeToggleStyle: ToggleStyle {
    
    func makeBody(configuration: Configuration) -> some View {
            HStack {
                configuration.label
//                Spacer()
                Rectangle()
                    .foregroundColor(configuration.isOn ? .black : .black)
                    .frame(width: 51, height: 31, alignment: .center)
                    .overlay(
                        Circle()
                            .foregroundColor(Color("switchColor"))
                            .padding(.all, 3)
                            .overlay(
                                Image(systemName: configuration.isOn ? "moon" : "sun.min")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .font(Font.title.weight(.light))
                                    .frame(width: 12, height: 12, alignment: .center)
                                    .foregroundColor(configuration.isOn ? .yellow : .white)
                            )
                            .offset(x: configuration.isOn ? 11 : -11, y: 0)
                            .animation(Animation.linear(duration: 0.1), value: configuration.isOn)
                            
                    )
                    .cornerRadius(20)
                    .onTapGesture { configuration.isOn.toggle() }
            }
        }
    
}
