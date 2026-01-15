## MicroExp – SwiftUI Micro‑Interactions

MicroExp is a small SwiftUI playground for “premium-feeling” micro-interactions: soft toggles, animated counters, and navigation patterns.

This repository is a SwiftUI app (not a standalone framework), but the views/styles under `MicroExp/` are intentionally reusable. This README documents those reusable building blocks as the project’s “public API”.

### Requirements

- Xcode: 15+ recommended
- Platforms: iOS (haptics are iOS-only; visuals work anywhere SwiftUI runs)

### Run

- Open `MicroExp.xcodeproj`
- Run the `MicroExp` scheme

### Component Gallery (in-app)

`MicroExpApp` launches `ContentView`, which renders a list of components (newest first) and navigates into a demo destination for each.

---

## API Reference (Components)

### `HeartCounterView`

**What it is**

An animated heart + counter button. Each tap increments a bound count (optionally capped), plays a light haptic (iOS only), and spawns a short “flying heart” burst animation.

**Source**

- `MicroExp/MicroExp/HeartCounterView.swift`

**Initializer / configuration**

Swift provides a memberwise initializer. The “API surface” you’re expected to use:

- `count: Binding<Int>` (required)
- `maxCount: Int? = nil`: If set and `count >= maxCount`, taps still animate/haptic but won’t increment.
- `accentColor: Color = .red`: Color for the flying heart burst.
- `useHaptics: Bool = true`: Controls whether taps generate haptics (`UIImpactFeedbackGenerator` on iOS).

**Usage example**

```swift
import SwiftUI

struct ExampleHeartCounter: View {
    @State private var likes = 0

    var body: some View {
        HeartCounterView(
            count: $likes,
            maxCount: 99,
            accentColor: .pink,
            useHaptics: true
        )
        .padding()
    }
}
```

**Behavior notes**

- `count` uses `.monospacedDigit()` and `.contentTransition(.numericText())` for smoother numeric changes.
- Haptics are guarded with `#if os(iOS)`; other platforms silently skip haptics.

---

### `SoftSwitchToggleStyle`

**What it is**

A reusable `ToggleStyle` that feels like pressing a soft physical switch: a subtle “squish” on touch-down and a springy knob transition on release.

**Source (used by the app target)**

- `MicroExp/SoftSwitchToggle.swift`

**Initializer / configuration**

No external parameters. Apply it to any `Toggle`.

**Usage example**

```swift
import SwiftUI

struct ExampleSoftSwitch: View {
    @State private var isOn = true

    var body: some View {
        Toggle("Soft Switch", isOn: $isOn)
            .toggleStyle(SoftSwitchToggleStyle())
            .padding()
    }
}
```

**Dependencies**

- Uses the asset color `switchColor` for the knob fill.

**Implementation notes**

- Interaction is handled via `DragGesture(minimumDistance: 0)` to detect touch-down and touch-up.
- The “pressed” state uses `@GestureState` for a transient squish effect.

---

### Side Panel (slide-in navigation + theme toggle)

This feature is a small set of cooperating components used together:

- `SidePanel`: container that positions the panel and handles background tap-to-dismiss.
- `SidePanelView`: the panel UI (icons + theme toggle).
- `ThemeToggleStyle`: a custom style used by the theme toggle.
- `MicroButton1`: an animated “menu / close” glyph used by the demo overlay button.
- `MainView`: a demo host that wires everything together.

#### `SidePanel`

**What it is**

An overlay container that slides a panel in/out from the trailing edge.

**Source**

- `MicroExp/SidePanel.swift`

**Initializer / configuration**

- `isSidebarVisible: Binding<Bool>` (required): controls whether the panel is shown.
- `sideBarWidth: CGFloat = UIScreen.main.bounds.size.width * 0.2`: panel width.
- `toggleTheme: Binding<Bool>` (required): toggles `.light` vs `.dark` via `environment(\.colorScheme, ...)`.

**Usage example**

```swift
import SwiftUI

struct ExampleSidePanelHost: View {
    @State private var isPanelVisible = false
    @State private var isLight = true

    var body: some View {
        ZStack {
            Color.yellow.ignoresSafeArea()

            SidePanel(isSidebarVisible: $isPanelVisible, toggleTheme: $isLight)
        }
        .overlay(alignment: .topTrailing) {
            Button { isPanelVisible.toggle() } label: {
                MicroButton1(isSelected: $isPanelVisible)
                    .foregroundColor(isLight ? .white : .black)
                    .padding([.top, .trailing], 28)
            }
        }
        .environment(\.colorScheme, isLight ? .light : .dark)
    }
}
```

**Dependencies**

- Uses the color asset `SidePanelColor` for panel background.

#### `SidePanelView`

**What it is**

The panel content: a vertical icon list with a selected state and a themed background “pill”, plus a theme toggle at the bottom.

**Source**

- `MicroExp/SidePanel.swift`

**Configuration**

- `toggleSwitch: Binding<Bool>` (required): drives icon colors and theme toggle.

#### `ThemeToggleStyle`

**What it is**

A custom `ToggleStyle` used for a small “moon/sun” switch.

**Source**

- `MicroExp/SidePanel.swift`

**Dependencies**

- Uses the asset color `switchColor` for the knob fill.

#### `MicroButton1`

**What it is**

An animated glyph built from capsules. In the demo it visually transitions between a “menu” and a rotated “close” shape as `isSelected` changes.

**Source**

- `MicroExp/MicroButton.swift`

**Configuration**

- `isSelected: Binding<Bool>` (required)

---

## App / Registry API

### `ContentView` and `ComponentItem`

`ContentView` is the in-app component registry. It defines `ComponentItem` and a local array of components, sorted by `addedAt` descending.

**Source**

- `MicroExp/MicroExp/ContentView.swift`

**Add a new component to the gallery**

Add a new `ComponentItem` entry:

```swift
ComponentItem(
    name: "My Component",
    symbol: "sparkles",
    addedAt: Date(), // or a fixed timestamp
    destination: AnyView(MyComponentDemo())
)
```

Notes:

- `destination` is stored as `AnyView` to allow heterogeneous destination view types in a single array.
- The list is sorted by `addedAt`, newest first.

---

## Asset Dependencies

Some components assume these color assets exist (in `MicroExp/Assets.xcassets`):

- `switchColor`: used by `SoftSwitchToggleStyle` and `ThemeToggleStyle`
- `SidePanelColor`: used by `SidePanel`

If you copy components into another project, copy these color assets too (or replace the `Color("...")` lookups).

---

## Notes / Known Pitfalls

- There is a second `SoftSwitchToggle.swift` under `MicroExp/MicroExp/` that is not referenced by the Xcode target. The app target uses `MicroExp/SoftSwitchToggle.swift`.
- Haptics are iOS-only; on non‑iOS platforms `useHaptics` has no effect.

