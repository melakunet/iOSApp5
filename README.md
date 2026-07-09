# Animal Friends

Animal Friends is a SwiftUI preschool app for iPhone. Children explore 8 animals — dog, cat, cow, lion, elephant, duck, horse, and sheep — by tapping cards on the home screen to hear each animal's sound, then watching a short video and reading a fun fact on the detail screen. A built-in quiz tab plays an animal sound and asks the child to tap the right picture from three choices, giving instant feedback with a bounce animation for a correct answer and a gentle shake for a wrong one.

## Features

| Feature | Technology |
|---|---|
| Animal sound playback | `AVAudioPlayer` (AVFoundation). Audio session set to `.playback` so sounds work on silent mode. |
| Video playback | `VideoPlayer` from AVKit. Player is paused automatically when the user navigates away. |
| Animal images | Image sets in `Assets.xcassets`, loaded with `Image(assetName)`. |
| Two-tab layout | `TabView` — Animals tab and Quiz tab, sharing one `SoundPlayer` via the SwiftUI environment. |
| Scrollable grid | `LazyVGrid` with 2 flexible columns inside a `ScrollView`. |
| Detail navigation | `NavigationStack` + `NavigationLink` inside the Animals tab. |
| Entrance animation | Staggered spring fade-in when the grid first appears (`opacity` + `offset`). |
| Sound feedback | Bounce scale animation on the active card while its sound plays. |
| Quiz animations | Spring celebration on a correct answer; `GeometryEffect` sine-wave shake on a wrong tap. |
| Accessibility | Every interactive element has an `accessibilityLabel`, and button traits are set so VoiceOver users can navigate the whole app. |

## How to run

1. Clone or download the project folder.
2. Open `iOSApp5.xcodeproj` in **Xcode 16** or later.
3. In the scheme picker, choose an iPhone simulator running **iOS 26** or later.
4. Press **⌘R** to build and run.

No third-party packages are used — the app depends only on Apple frameworks (SwiftUI, AVFoundation, AVKit).

## Running the tests

- **Unit tests** — Press **⌘U** or go to Product → Test. All unit tests run in the iOSApp5Tests target and verify the data model and audio logic.
- **UI tests** — The iOSApp5UITests target drives the simulator. Make sure **Simulator.app** is open before running UI tests; the first run after a cold boot may fail with an authorization error until the Simulator window is visible.

## Media credits

Animal images were generated with ChatGPT. Video clips were generated with [Kling AI](https://kling.ai). Animal sound effects are royalty-free files sourced from [Pixabay](https://pixabay.com) and [Mixkit](https://mixkit.co).
