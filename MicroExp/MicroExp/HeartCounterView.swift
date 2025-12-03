//
//  HeartCounterView.swift
//  MicroExp
//
//  Created by Vishal Paliwal on 03/12/25.
//

import SwiftUI
struct HeartCounterView: View {
    
    @Binding var count: Int
    
    var maxCount: Int? = nil
    
    var accentColor: Color = .red
    
    var useHaptics: Bool = true
    
    @State private var isPressed: Bool = false
    
    @State private var flyingHearts: [FlyingHeart] = []
    
    struct FlyingHeart: Identifiable {
        let id = UUID()
        var direction: CGFloat
    }
    
    var body: some View {
        buttonContent
    }
    
    private var buttonContent: some View {
        Button(action: handleTap) {
            HStack(spacing: 14) {
                ZStack {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Color.gray)
                        .scaleEffect(isPressed ? 1.15 : 1.0)
                        .shadow(color: Color.black.opacity(0.25),
                                radius: 4,
                                x: 0,
                                y: 2)
                        .animation(.easeOut(duration: 0.12), value: isPressed)
                    
                    ForEach(flyingHearts) { heart in
                        FlyingHeartView(
                            color: accentColor,
                            direction: heart.direction
                        ) {
                            if let index = flyingHearts.firstIndex(where: { $0.id == heart.id }) {
                                flyingHearts.remove(at: index)
                            }
                        }
                        .allowsHitTesting(false)
                    }
                }
                
                Text("\(count)")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.primary)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.snappy(duration: 0.35), value: count)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 12)
            .background(
                Capsule(style: .continuous)
                    .fill(.bar)
                    .shadow(color: Color.black.opacity(0.12),
                            radius: 12,
                            x: 0,
                            y: 6)
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.28,
                               dampingFraction: 0.75,
                               blendDuration: 0.1),
                       value: isPressed)
        }
        .buttonStyle(.plain)
    }
    
    private func handleTap() {
        if let maxCount, count >= maxCount {
            triggerPressAnimation()
            spawnFlyingHeart()
            playHaptic()
            return
        }
        
        count += 1
        triggerPressAnimation()
        spawnFlyingHeart()
        playHaptic()
    }
    
    private func triggerPressAnimation() {
        withAnimation {
            isPressed = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            withAnimation {
                isPressed = false
            }
        }
    }
    
    private func spawnFlyingHeart() {
        let direction: CGFloat = Bool.random() ? -1 : 1
        let heart = FlyingHeart(direction: direction)
        flyingHearts.append(heart)
    }
    
    private func playHaptic() {
        guard useHaptics else { return }
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }
}

private struct FlyingHeartView: View {
    
    var color: Color
    var direction: CGFloat
    var onFinish: () -> Void
    
    @State private var travel: CGFloat = 0
    @State private var fade: Double = 1.0
    @State private var scale: CGFloat = 1.05
    @State private var wingFlap: CGFloat = 0.0
    @State private var showWings: Bool = false
    
    private let totalDuration: Double = 1.0
    private let coverDelay: Double = 0.16
    
    var body: some View {
        ZStack {
            ZStack {
                if showWings {
                    WingLeft()
                        .fill(Color.white)
                        .frame(width: 32, height: 22)
                        .shadow(color: .black.opacity(0.12),
                                radius: 4,
                                x: 0,
                                y: 2)
                        .offset(x: 10, y: -4)
                        .rotationEffect(.degrees(28 + 10 * Double(wingFlap)))
                    
                    WingRight()
                        .fill(Color.white)
                        .frame(width: 32, height: 22)
                        .shadow(color: .black.opacity(0.12),
                                radius: 4,
                                x: 0,
                                y: 2)
                        .offset(x: -10, y: 0)
                        .rotationEffect(.degrees(-18 - 10 * Double(wingFlap)))
                }

                Image(systemName: "heart.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(color)
                    .shadow(color: color.opacity(0.5),
                            radius: 8,
                            x: 0,
                            y: 3)
            }
            .scaleEffect(scale)
            .opacity(fade)
            .offset(currentOffset())
            .rotationEffect(.degrees(Double(travel) * 18.0 * Double(direction)))
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func currentOffset() -> CGSize {
        let lift: CGFloat = -80
        let horizontalSpread: CGFloat = 40 * direction
        
        let t = travel
        let easedT = 1 - pow(1 - t, 2)
        
        let y = lift * easedT
        let x = horizontalSpread * easedT
        
        return CGSize(width: x, height: y)
    }
    
    private func startAnimation() {
        travel = 0
        fade = 1.0
        scale = 1.05
        wingFlap = 0.0
        showWings = false
        wingFlap = 0.0
        
        withAnimation(.easeInOut(duration: 0.18).delay(coverDelay)) {
            showWings = true
        }
        
        withAnimation(.easeOut(duration: totalDuration).delay(coverDelay)) {
            travel = 1.0
            scale = 1.12
        }
        
        withAnimation(.easeOut(duration: totalDuration * 0.5).delay(coverDelay + totalDuration * 0.4)) {
            fade = 0.0
        }
        
        withAnimation(.easeInOut(duration: totalDuration / 4).delay(coverDelay).repeatCount(3, autoreverses: true)) {
            wingFlap = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
            onFinish()
        }
    }
}

struct HeartCounterView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HeartCounterPreviewWrapper()
                .preferredColorScheme(.light)
            
            HeartCounterPreviewWrapper()
                .preferredColorScheme(.dark)
        }
    }
}

struct FlyingHeartView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ZStack {
                WingLeft()
                    .fill(Color.white)
                    .frame(width: 32, height: 22)
                    .shadow(color: .black.opacity(0.12),
                            radius: 4,
                            x: 0,
                            y: 2)
                    .offset(x: 10, y: -4)
                    .rotationEffect(.degrees(28))
                
                WingRight()
                    .fill(Color.white)
                    .frame(width: 32, height: 22)
                    .shadow(color: .black.opacity(0.12),
                            radius: 4,
                            x: 0,
                            y: 2)
                    .offset(x: -10, y: 0)
                    .rotationEffect(.degrees(-18))
                
                Image(systemName: "heart.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.red)
                    .shadow(color: Color.red.opacity(0.5),
                            radius: 8,
                            x: 0,
                            y: 3)
            }
        }
        .previewLayout(.sizeThatFits)
    }
}

struct HeartCounterPreviewWrapper: View {
    @State private var count: Int = 0
    
    var body: some View {
        ZStack {
//            Color("SidePanelColor")
//                .ignoresSafeArea()
            
            HeartCounterView(count: $count,
                             maxCount: nil,
                             accentColor: .red,
                             useHaptics: true)
        }
        .preferredColorScheme(.dark)
    }
}

struct WingRight: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0, y: 0))
        path.addCurve(to: CGPoint(x: 0.01501*width, y: 0.02051*height), control1: CGPoint(x: 0.00705*width, y: 0.00574*height), control2: CGPoint(x: 0.01075*width, y: 0.01257*height))
        path.addCurve(to: CGPoint(x: 0.10352*width, y: 0.12109*height), control1: CGPoint(x: 0.0365*width, y: 0.05928*height), control2: CGPoint(x: 0.06846*width, y: 0.09421*height))
        path.addCurve(to: CGPoint(x: 0.10717*width, y: 0.12392*height), control1: CGPoint(x: 0.10472*width, y: 0.12203*height), control2: CGPoint(x: 0.10593*width, y: 0.12296*height))
        path.addCurve(to: CGPoint(x: 0.35171*width, y: 0.23147*height), control1: CGPoint(x: 0.17891*width, y: 0.17894*height), control2: CGPoint(x: 0.26467*width, y: 0.21007*height))
        path.addCurve(to: CGPoint(x: 0.35691*width, y: 0.23275*height), control1: CGPoint(x: 0.35343*width, y: 0.23189*height), control2: CGPoint(x: 0.35514*width, y: 0.23231*height))
        path.addCurve(to: CGPoint(x: 0.38248*width, y: 0.23891*height), control1: CGPoint(x: 0.36543*width, y: 0.23484*height), control2: CGPoint(x: 0.37395*width, y: 0.2369*height))
        path.addCurve(to: CGPoint(x: 0.51827*width, y: 0.32476*height), control1: CGPoint(x: 0.43597*width, y: 0.25171*height), control2: CGPoint(x: 0.48736*width, y: 0.27731*height))
        path.addCurve(to: CGPoint(x: 0.52148*width, y: 0.33008*height), control1: CGPoint(x: 0.51933*width, y: 0.32652*height), control2: CGPoint(x: 0.52039*width, y: 0.32827*height))
        path.addCurve(to: CGPoint(x: 0.52537*width, y: 0.33643*height), control1: CGPoint(x: 0.52277*width, y: 0.33218*height), control2: CGPoint(x: 0.52405*width, y: 0.33427*height))
        path.addCurve(to: CGPoint(x: 0.54284*width, y: 0.37701*height), control1: CGPoint(x: 0.53297*width, y: 0.34943*height), control2: CGPoint(x: 0.53859*width, y: 0.36257*height))
        path.addCurve(to: CGPoint(x: 0.54435*width, y: 0.3821*height), control1: CGPoint(x: 0.54334*width, y: 0.37869*height), control2: CGPoint(x: 0.54383*width, y: 0.38037*height))
        path.addCurve(to: CGPoint(x: 0.55859*width, y: 0.44458*height), control1: CGPoint(x: 0.55027*width, y: 0.40267*height), control2: CGPoint(x: 0.55441*width, y: 0.4236*height))
        path.addCurve(to: CGPoint(x: 0.56364*width, y: 0.46938*height), control1: CGPoint(x: 0.56027*width, y: 0.45285*height), control2: CGPoint(x: 0.56195*width, y: 0.46112*height))
        path.addCurve(to: CGPoint(x: 0.56488*width, y: 0.47543*height), control1: CGPoint(x: 0.56405*width, y: 0.47138*height), control2: CGPoint(x: 0.56446*width, y: 0.47337*height))
        path.addCurve(to: CGPoint(x: 0.5769*width, y: 0.52813*height), control1: CGPoint(x: 0.56849*width, y: 0.49309*height), control2: CGPoint(x: 0.57248*width, y: 0.51065*height))
        path.addCurve(to: CGPoint(x: 0.58008*width, y: 0.56055*height), control1: CGPoint(x: 0.58221*width, y: 0.54985*height), control2: CGPoint(x: 0.58221*width, y: 0.54985*height))
        path.addCurve(to: CGPoint(x: 0.56848*width, y: 0.56726*height), control1: CGPoint(x: 0.57622*width, y: 0.56552*height), control2: CGPoint(x: 0.57488*width, y: 0.56631*height))
        path.addCurve(to: CGPoint(x: 0.55856*width, y: 0.56377*height), control1: CGPoint(x: 0.5625*width, y: 0.56641*height), control2: CGPoint(x: 0.5625*width, y: 0.56641*height))
        path.addCurve(to: CGPoint(x: 0.54928*width, y: 0.53745*height), control1: CGPoint(x: 0.55259*width, y: 0.55579*height), control2: CGPoint(x: 0.55132*width, y: 0.54709*height))
        path.addCurve(to: CGPoint(x: 0.54785*width, y: 0.53105*height), control1: CGPoint(x: 0.54881*width, y: 0.53534*height), control2: CGPoint(x: 0.54833*width, y: 0.53323*height))
        path.addCurve(to: CGPoint(x: 0.54333*width, y: 0.51038*height), control1: CGPoint(x: 0.54632*width, y: 0.52416*height), control2: CGPoint(x: 0.54483*width, y: 0.51727*height))
        path.addCurve(to: CGPoint(x: 0.54019*width, y: 0.49618*height), control1: CGPoint(x: 0.54229*width, y: 0.50564*height), control2: CGPoint(x: 0.54124*width, y: 0.50091*height))
        path.addCurve(to: CGPoint(x: 0.52619*width, y: 0.43057*height), control1: CGPoint(x: 0.53535*width, y: 0.47435*height), control2: CGPoint(x: 0.53067*width, y: 0.45249*height))
        path.addCurve(to: CGPoint(x: 0.44662*width, y: 0.29372*height), control1: CGPoint(x: 0.51445*width, y: 0.37316*height), control2: CGPoint(x: 0.49659*width, y: 0.32842*height))
        path.addCurve(to: CGPoint(x: 0.35723*width, y: 0.26187*height), control1: CGPoint(x: 0.41935*width, y: 0.27628*height), control2: CGPoint(x: 0.38828*width, y: 0.26942*height))
        path.addCurve(to: CGPoint(x: 0.16406*width, y: 0.19336*height), control1: CGPoint(x: 0.29014*width, y: 0.2455*height), control2: CGPoint(x: 0.22528*width, y: 0.22603*height))
        path.addCurve(to: CGPoint(x: 0.15984*width, y: 0.19113*height), control1: CGPoint(x: 0.16267*width, y: 0.19263*height), control2: CGPoint(x: 0.16128*width, y: 0.19189*height))
        path.addCurve(to: CGPoint(x: -0.00391*width, y: 0.04492*height), control1: CGPoint(x: 0.0943*width, y: 0.15643*height), control2: CGPoint(x: 0.03611*width, y: 0.10788*height))
        path.addCurve(to: CGPoint(x: -0.00391*width, y: 0.12891*height), control1: CGPoint(x: -0.01388*width, y: 0.07027*height), control2: CGPoint(x: -0.0137*width, y: 0.10356*height))
        path.addCurve(to: CGPoint(x: -0.0024*width, y: 0.13363*height), control1: CGPoint(x: -0.00341*width, y: 0.13046*height), control2: CGPoint(x: -0.00291*width, y: 0.13202*height))
        path.addCurve(to: CGPoint(x: 0.13019*width, y: 0.25599*height), control1: CGPoint(x: 0.01701*width, y: 0.18961*height), control2: CGPoint(x: 0.07958*width, y: 0.23099*height))
        path.addCurve(to: CGPoint(x: 0.29086*width, y: 0.29384*height), control1: CGPoint(x: 0.18049*width, y: 0.28002*height), control2: CGPoint(x: 0.23548*width, y: 0.29046*height))
        path.addCurve(to: CGPoint(x: 0.29761*width, y: 0.29428*height), control1: CGPoint(x: 0.2942*width, y: 0.29405*height), control2: CGPoint(x: 0.2942*width, y: 0.29405*height))
        path.addCurve(to: CGPoint(x: 0.31051*width, y: 0.29493*height), control1: CGPoint(x: 0.30191*width, y: 0.29454*height), control2: CGPoint(x: 0.30621*width, y: 0.29476*height))
        path.addCurve(to: CGPoint(x: 0.33146*width, y: 0.30151*height), control1: CGPoint(x: 0.32492*width, y: 0.29578*height), control2: CGPoint(x: 0.32492*width, y: 0.29578*height))
        path.addCurve(to: CGPoint(x: 0.33203*width, y: 0.31836*height), control1: CGPoint(x: 0.33471*width, y: 0.30811*height), control2: CGPoint(x: 0.33434*width, y: 0.31143*height))
        path.addCurve(to: CGPoint(x: 0.31165*width, y: 0.32288*height), control1: CGPoint(x: 0.32497*width, y: 0.32307*height), control2: CGPoint(x: 0.31982*width, y: 0.32294*height))
        path.addCurve(to: CGPoint(x: 0.30704*width, y: 0.32285*height), control1: CGPoint(x: 0.30936*width, y: 0.32286*height), control2: CGPoint(x: 0.30936*width, y: 0.32286*height))
        path.addCurve(to: CGPoint(x: 0.0508*width, y: 0.23886*height), control1: CGPoint(x: 0.21385*width, y: 0.3211*height), control2: CGPoint(x: 0.12444*width, y: 0.29681*height))
        path.addCurve(to: CGPoint(x: 0.0332*width, y: 0.22656*height), control1: CGPoint(x: 0.04506*width, y: 0.23448*height), control2: CGPoint(x: 0.03925*width, y: 0.2305*height))
        path.addCurve(to: CGPoint(x: 0.07031*width, y: 0.32227*height), control1: CGPoint(x: 0.03634*width, y: 0.26335*height), control2: CGPoint(x: 0.0426*width, y: 0.29577*height))
        path.addCurve(to: CGPoint(x: 0.08984*width, y: 0.33594*height), control1: CGPoint(x: 0.07655*width, y: 0.32731*height), control2: CGPoint(x: 0.08306*width, y: 0.33167*height))
        path.addCurve(to: CGPoint(x: 0.09499*width, y: 0.33934*height), control1: CGPoint(x: 0.09239*width, y: 0.33762*height), control2: CGPoint(x: 0.09239*width, y: 0.33762*height))
        path.addCurve(to: CGPoint(x: 0.28261*width, y: 0.36238*height), control1: CGPoint(x: 0.15084*width, y: 0.37439*height), control2: CGPoint(x: 0.21976*width, y: 0.3762*height))
        path.addCurve(to: CGPoint(x: 0.29575*width, y: 0.35916*height), control1: CGPoint(x: 0.287*width, y: 0.36135*height), control2: CGPoint(x: 0.29138*width, y: 0.36027*height))
        path.addCurve(to: CGPoint(x: 0.31445*width, y: 0.35742*height), control1: CGPoint(x: 0.30249*width, y: 0.35748*height), control2: CGPoint(x: 0.30757*width, y: 0.35648*height))
        path.addCurve(to: CGPoint(x: 0.32227*width, y: 0.36523*height), control1: CGPoint(x: 0.31921*width, y: 0.36047*height), control2: CGPoint(x: 0.31921*width, y: 0.36047*height))
        path.addCurve(to: CGPoint(x: 0.32031*width, y: 0.37891*height), control1: CGPoint(x: 0.32239*width, y: 0.37219*height), control2: CGPoint(x: 0.32239*width, y: 0.37219*height))
        path.addCurve(to: CGPoint(x: 0.28882*width, y: 0.38977*height), control1: CGPoint(x: 0.31143*width, y: 0.38628*height), control2: CGPoint(x: 0.29984*width, y: 0.38757*height))
        path.addCurve(to: CGPoint(x: 0.28251*width, y: 0.39105*height), control1: CGPoint(x: 0.28674*width, y: 0.39019*height), control2: CGPoint(x: 0.28465*width, y: 0.39061*height))
        path.addCurve(to: CGPoint(x: 0.10938*width, y: 0.37891*height), control1: CGPoint(x: 0.22342*width, y: 0.40264*height), control2: CGPoint(x: 0.16582*width, y: 0.40086*height))
        path.addCurve(to: CGPoint(x: 0.13672*width, y: 0.42383*height), control1: CGPoint(x: 0.11706*width, y: 0.39532*height), control2: CGPoint(x: 0.12488*width, y: 0.40995*height))
        path.addCurve(to: CGPoint(x: 0.1404*width, y: 0.4287*height), control1: CGPoint(x: 0.13793*width, y: 0.42544*height), control2: CGPoint(x: 0.13915*width, y: 0.42705*height))
        path.addCurve(to: CGPoint(x: 0.21488*width, y: 0.46547*height), control1: CGPoint(x: 0.15854*width, y: 0.45019*height), control2: CGPoint(x: 0.18742*width, y: 0.46256*height))
        path.addCurve(to: CGPoint(x: 0.34216*width, y: 0.41946*height), control1: CGPoint(x: 0.26087*width, y: 0.4672*height), control2: CGPoint(x: 0.3054*width, y: 0.44523*height))
        path.addCurve(to: CGPoint(x: 0.36133*width, y: 0.41602*height), control1: CGPoint(x: 0.34912*width, y: 0.4151*height), control2: CGPoint(x: 0.35326*width, y: 0.4148*height))
        path.addCurve(to: CGPoint(x: 0.36719*width, y: 0.42383*height), control1: CGPoint(x: 0.36523*width, y: 0.41907*height), control2: CGPoint(x: 0.36523*width, y: 0.41907*height))
        path.addCurve(to: CGPoint(x: 0.36523*width, y: 0.4375*height), control1: CGPoint(x: 0.36792*width, y: 0.43018*height), control2: CGPoint(x: 0.36792*width, y: 0.43018*height))
        path.addCurve(to: CGPoint(x: 0.22266*width, y: 0.49414*height), control1: CGPoint(x: 0.33192*width, y: 0.47256*height), control2: CGPoint(x: 0.26922*width, y: 0.49103*height))
        path.addCurve(to: CGPoint(x: 0.28296*width, y: 0.52441*height), control1: CGPoint(x: 0.23947*width, y: 0.512*height), control2: CGPoint(x: 0.25775*width, y: 0.52341*height))
        path.addCurve(to: CGPoint(x: 0.38452*width, y: 0.47339*height), control1: CGPoint(x: 0.32227*width, y: 0.52278*height), control2: CGPoint(x: 0.35675*width, y: 0.49956*height))
        path.addCurve(to: CGPoint(x: 0.39795*width, y: 0.46765*height), control1: CGPoint(x: 0.39063*width, y: 0.46875*height), control2: CGPoint(x: 0.39063*width, y: 0.46875*height))
        path.addCurve(to: CGPoint(x: 0.40808*width, y: 0.47083*height), control1: CGPoint(x: 0.4043*width, y: 0.46875*height), control2: CGPoint(x: 0.4043*width, y: 0.46875*height))
        path.addCurve(to: CGPoint(x: 0.41016*width, y: 0.48828*height), control1: CGPoint(x: 0.41158*width, y: 0.4772*height), control2: CGPoint(x: 0.41135*width, y: 0.48113*height))
        path.addCurve(to: CGPoint(x: 0.32422*width, y: 0.54492*height), control1: CGPoint(x: 0.39405*width, y: 0.51337*height), control2: CGPoint(x: 0.35163*width, y: 0.53615*height))
        path.addCurve(to: CGPoint(x: 0.39063*width, y: 0.55859*height), control1: CGPoint(x: 0.34588*width, y: 0.55695*height), control2: CGPoint(x: 0.3658*width, y: 0.56385*height))
        path.addCurve(to: CGPoint(x: 0.44485*width, y: 0.52094*height), control1: CGPoint(x: 0.41354*width, y: 0.5515*height), control2: CGPoint(x: 0.42915*width, y: 0.53865*height))
        path.addCurve(to: CGPoint(x: 0.46094*width, y: 0.51758*height), control1: CGPoint(x: 0.45055*width, y: 0.51655*height), control2: CGPoint(x: 0.4539*width, y: 0.51671*height))
        path.addCurve(to: CGPoint(x: 0.46875*width, y: 0.52539*height), control1: CGPoint(x: 0.46558*width, y: 0.52075*height), control2: CGPoint(x: 0.46558*width, y: 0.52075*height))
        path.addCurve(to: CGPoint(x: 0.46516*width, y: 0.54247*height), control1: CGPoint(x: 0.46975*width, y: 0.53287*height), control2: CGPoint(x: 0.4694*width, y: 0.53613*height))
        path.addCurve(to: CGPoint(x: 0.42969*width, y: 0.57227*height), control1: CGPoint(x: 0.45436*width, y: 0.55393*height), control2: CGPoint(x: 0.4435*width, y: 0.56448*height))
        path.addCurve(to: CGPoint(x: 0.42578*width, y: 0.57227*height), control1: CGPoint(x: 0.4284*width, y: 0.57227*height), control2: CGPoint(x: 0.42711*width, y: 0.57227*height))
        path.addCurve(to: CGPoint(x: 0.45313*width, y: 0.58594*height), control1: CGPoint(x: 0.43338*width, y: 0.58068*height), control2: CGPoint(x: 0.44214*width, y: 0.58371*height))
        path.addCurve(to: CGPoint(x: 0.48122*width, y: 0.58565*height), control1: CGPoint(x: 0.46249*width, y: 0.58634*height), control2: CGPoint(x: 0.47185*width, y: 0.58612*height))
        path.addCurve(to: CGPoint(x: 0.50124*width, y: 0.58947*height), control1: CGPoint(x: 0.49494*width, y: 0.58515*height), control2: CGPoint(x: 0.49494*width, y: 0.58515*height))
        path.addCurve(to: CGPoint(x: 0.50391*width, y: 0.60547*height), control1: CGPoint(x: 0.50483*width, y: 0.59523*height), control2: CGPoint(x: 0.5049*width, y: 0.5988*height))
        path.addCurve(to: CGPoint(x: 0.49023*width, y: 0.61328*height), control1: CGPoint(x: 0.50012*width, y: 0.61095*height), control2: CGPoint(x: 0.49659*width, y: 0.61202*height))
        path.addCurve(to: CGPoint(x: 0.46851*width, y: 0.61377*height), control1: CGPoint(x: 0.483*width, y: 0.61377*height), control2: CGPoint(x: 0.47576*width, y: 0.61373*height))
        path.addCurve(to: CGPoint(x: 0.46262*width, y: 0.61389*height), control1: CGPoint(x: 0.46559*width, y: 0.61383*height), control2: CGPoint(x: 0.46559*width, y: 0.61383*height))
        path.addCurve(to: CGPoint(x: 0.41528*width, y: 0.60168*height), control1: CGPoint(x: 0.44533*width, y: 0.61398*height), control2: CGPoint(x: 0.4301*width, y: 0.61096*height))
        path.addCurve(to: CGPoint(x: 0.4106*width, y: 0.59882*height), control1: CGPoint(x: 0.41374*width, y: 0.60074*height), control2: CGPoint(x: 0.41219*width, y: 0.5998*height))
        path.addCurve(to: CGPoint(x: 0.40298*width, y: 0.59142*height), control1: CGPoint(x: 0.40625*width, y: 0.5957*height), control2: CGPoint(x: 0.40625*width, y: 0.5957*height))
        path.addCurve(to: CGPoint(x: 0.37927*width, y: 0.58789*height), control1: CGPoint(x: 0.39569*width, y: 0.58575*height), control2: CGPoint(x: 0.38819*width, y: 0.58742*height))
        path.addCurve(to: CGPoint(x: 0.29431*width, y: 0.55896*height), control1: CGPoint(x: 0.34752*width, y: 0.58868*height), control2: CGPoint(x: 0.31839*width, y: 0.58081*height))
        path.addCurve(to: CGPoint(x: 0.2658*width, y: 0.55019*height), control1: CGPoint(x: 0.28556*width, y: 0.55171*height), control2: CGPoint(x: 0.27669*width, y: 0.55112*height))
        path.addCurve(to: CGPoint(x: 0.21289*width, y: 0.52539*height), control1: CGPoint(x: 0.24485*width, y: 0.54826*height), control2: CGPoint(x: 0.22841*width, y: 0.53931*height))
        path.addCurve(to: CGPoint(x: 0.20882*width, y: 0.5218*height), control1: CGPoint(x: 0.21155*width, y: 0.5242*height), control2: CGPoint(x: 0.2102*width, y: 0.52302*height))
        path.addCurve(to: CGPoint(x: 0.1908*width, y: 0.49854*height), control1: CGPoint(x: 0.20117*width, y: 0.51463*height), control2: CGPoint(x: 0.19592*width, y: 0.50769*height))
        path.addCurve(to: CGPoint(x: 0.16776*width, y: 0.48229*height), control1: CGPoint(x: 0.18452*width, y: 0.48818*height), control2: CGPoint(x: 0.17917*width, y: 0.48555*height))
        path.addCurve(to: CGPoint(x: 0.08984*width, y: 0.40625*height), control1: CGPoint(x: 0.13416*width, y: 0.47146*height), control2: CGPoint(x: 0.10547*width, y: 0.43654*height))
        path.addCurve(to: CGPoint(x: 0.07556*width, y: 0.36609*height), control1: CGPoint(x: 0.08376*width, y: 0.39327*height), control2: CGPoint(x: 0.07875*width, y: 0.38007*height))
        path.addCurve(to: CGPoint(x: 0.05469*width, y: 0.3457*height), control1: CGPoint(x: 0.07241*width, y: 0.3548*height), control2: CGPoint(x: 0.06438*width, y: 0.35125*height))
        path.addCurve(to: CGPoint(x: 0.0089*width, y: 0.2673*height), control1: CGPoint(x: 0.02909*width, y: 0.32837*height), control2: CGPoint(x: 0.01499*width, y: 0.29651*height))
        path.addCurve(to: CGPoint(x: 0.00839*width, y: 0.23792*height), control1: CGPoint(x: 0.00746*width, y: 0.25736*height), control2: CGPoint(x: 0.00785*width, y: 0.24792*height))
        path.addCurve(to: CGPoint(x: 0.00093*width, y: 0.18892*height), control1: CGPoint(x: 0.01053*width, y: 0.21204*height), control2: CGPoint(x: 0.01053*width, y: 0.21204*height))
        path.addCurve(to: CGPoint(x: -0.01086*width, y: 0.17691*height), control1: CGPoint(x: -0.00288*width, y: 0.18479*height), control2: CGPoint(x: -0.00683*width, y: 0.18083*height))
        path.addCurve(to: CGPoint(x: -0.03786*width, y: 0.07439*height), control1: CGPoint(x: -0.03545*width, y: 0.14998*height), control2: CGPoint(x: -0.03881*width, y: 0.10881*height))
        path.addCurve(to: CGPoint(x: -0.01672*width, y: 0.00236*height), control1: CGPoint(x: -0.03671*width, y: 0.051*height), control2: CGPoint(x: -0.03169*width, y: 0.02103*height))
        path.addCurve(to: CGPoint(x: 0, y: 0), control1: CGPoint(x: -0.01135*width, y: -0.00179*height), control2: CGPoint(x: -0.00648*width, y: -0.0008*height))
        path.closeSubpath()
        return path
    }
}

struct WingLeft: Shape {
    func path(in rect: CGRect) -> Path {
        let original = WingRight().path(in: rect)
        var transform = CGAffineTransform.identity
        transform = transform
            .translatedBy(x: rect.maxX, y: 0)
            .scaledBy(x: -1, y: 1)
        return original.applying(transform)
    }
}

struct WingShapes_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 40) {
            WingLeft()
                .stroke(Color.blue, lineWidth: 1)
                .background(WingLeft().fill(Color.blue.opacity(0.2)))
                .frame(width: 160, height: 120)
            
            WingRight()
                .stroke(Color.blue, lineWidth: 1)
                .background(WingRight().fill(Color.pink.opacity(0.2)))
                .frame(width: 160, height: 120)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}


