# EnglishCallingApp

A real-time iOS app for practicing English through live audio calls. The project provides a mobile client that establishes peer-to-peer audio sessions using WebRTC and a lightweight Node.js signaling server to coordinate session setup. Implementations prioritize correctness, low-latency audio, and a clear MVVM-based code organization.

## Overview
EnglishCallingApp enables two users to connect over audio calls for language practice. It handles microphone capture, real-time transport with WebRTC, and session signaling while keeping presentation and business logic separated for maintainability and testability.

## Key features
- Peer-to-peer real-time audio calls using WebRTC
- Node.js signaling server for SDP and ICE exchange
- MVVM architecture with clear separation of View, ViewModel, and Services
- Low-level WebRTC integration and performance-sensitive logic
- Mixed Swift/SwiftUI and UIKit UI with Objective-C bridges for WebRTC components

## Technical architecture
- iOS client: UI (SwiftUI + UIKit) ⇄ ViewModels (MVVM) ⇄ WebRTC layer (Objective-C/Swift wrappers)
- Signaling server: Node.js WebSocket/HTTP server that brokers offers/answers and ICE candidates
- Media path: direct peer-to-peer audio transport (WebRTC) once signaling completes
- Responsibilities:
  - Client: UI, local media capture, peer connection lifecycle, reconnection and retry logic
  - Server: session management and lightweight signaling only

## Tech stack
- Client
  - Languages: Swift (UI, view models), Objective-C (WebRTC integration)
  - Frameworks: SwiftUI, UIKit, WebRTC (GoogleWebRTC or equivalent)
  - Architecture: MVVM
- Backend
  - Node.js (signaling server)
  - WebSocket / HTTP for signaling
- Tooling
  - Xcode (build & run)
  - CocoaPods or Swift Package Manager for iOS dependencies
  - Node/npm for server

## High-level folder structure
- /ios or /App
  - Views/          — SwiftUI / UIKit views
  - ViewModels/     — MVVM view models and presentation logic
  - Services/       — signaling client, WebRTC manager, audio utilities
  - Vendor/         — prebuilt WebRTC artifacts or third-party frameworks (if present)
  - Resources/      — Info.plist, assets, permissions
- /server
  - index.js / server.js — Node.js signaling entry point
  - package.json         — server dependencies and scripts
- /Scripts or /tools    — build helpers, generation scripts
- /Tests                — unit / integration tests (when present)
- README.md             — this document

(Adjust paths to match repository layout.)

## How to run (basic)
Prerequisites
- macOS with Xcode (recommended)
- Node.js (14+)
- CocoaPods or Swift Package Manager (as used by the project)
- Physical iOS device for full audio testing (simulator has limited audio I/O)

Server
1. Clone the repo:
   - git clone https://github.com/kirtidhwajpatra/EnglishCallingApp.git
2. Start the signaling server:
   - cd EnglishCallingApp/server
   - npm install
   - npm start
3. Verify server logs and configured port.

iOS client
1. Resolve iOS dependencies:
   - If Podfile exists:
     - cd EnglishCallingApp/ios (or project root)
     - pod install
     - open the workspace (.xcworkspace)
   - If SPM is used:
     - open the Xcode project and let SPM resolve packages
2. Configure runtime settings:
   - Set the signaling server URL in app configuration (Config/Constants)
   - Set a valid signing team and bundle identifier
   - Ensure Info.plist includes NSMicrophoneUsageDescription
   - Enable Background Modes → Audio if required
3. Build & run on a device:
   - Select a physical device and run from Xcode
   - Use two devices (or simulator + device where supported) pointed at the same signaling server to verify end-to-end audio

Notes
- WebRTC frameworks may require prebuilt binaries or specific Pod/SPM configuration. Follow repository-specific instructions if available.
- For NAT traversal reliability, a TURN server may be required for some network environments.

## Status
In development — core audio calling and signaling features implemented; polish and extended features remain.

## Future improvements
- VoIP push notifications (PushKit) for reliable incoming-call delivery
- TURN server integration for improved connectivity across restrictive NATs
- Automated tests for signaling and connection lifecycle
- Audio quality tuning: adaptive bitrate and echo cancellation tuning
- Session recording, analytics, and privacy-aware logging
- Optional group call capability and basic moderation controls

## Contribution guidelines
Submit focused pull requests with:
- A concise change description
- Relevant tests or manual test steps
- Any dependency or setup updates reflected in the README or scripts

Refer to the repository LICENSE file for usage and distribution terms.
