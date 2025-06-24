//
//  isletApp.swift
//  islet
//
//  Created by calin on 24.06.2025.
//

import SwiftUI

@main
struct isletApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class MainNSPanel: NSPanel {
    override var canBecomeMain: Bool {
        return true
    }
    override var canBecomeKey: Bool {
        return true
    }

}

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: MainNSPanel!

    func applicationDidFinishLaunching(_ notification: Notification) {

        let viewModel = ViewModel(app: self)

        // Create the SwiftUI view
        let contentView = ContentView(viewModel: viewModel)

        let rect = {
            var rect = NSRect()
            rect.size = viewModel.sizeState.asSize()
            return rect.atScreenCenter()
        }
        // Create the borderless window
        let panel = MainNSPanel.init(
            contentRect: rect(),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false,
        )

        panel.isOpaque = false
        panel.backgroundColor = NSColor.clear
        //panel.setFrameAutosaveName("Main Window")
        panel.contentView = NSHostingView(rootView: contentView)
        //panel.makeKeyAndOrderFront(nil)
        panel.level = NSWindow.Level.mainMenu + 1
        panel.makeKeyAndOrderFront(nil)
        panel.collectionBehavior = .ignoresCycle
        panel.hasShadow = false
        // panel.isFloatingPanel = true

        self.window = panel
    }
}

extension NSRect {
    func atScreenCenter() -> NSRect {
        guard let screen = NSScreen.main else { return self }
        let screenFrame = screen.frame
        let windowSize = self.size

        let xPos = screenFrame.origin.x + (screenFrame.width - windowSize.width) / 2
        let yPos = screenFrame.origin.y + screenFrame.height - windowSize.height + 6

        return NSRect(
            x: xPos,
            y: yPos,
            width: self.width,
            height: self.height
        )

    }
}

enum AppSizeStateEvent {
    case hovered
    case unhovered
    case clicked
}

enum Information {

}

enum AppSizeState {
    case hidden
    case idle(
        info: [Information]
    )
    case hiddenHover
    case hover(
        info: [Information]
    )
    case open(
        info: [Information]
    )
    case openHovered(
        info: [Information]
    )

    func reduce(event: AppSizeStateEvent) -> AppSizeState {
        switch (self, event) {
        // idle
        case (.idle(let info), .hovered):
            return .hover(info: info)
        case (.idle(let info), .clicked):
            return .openHovered(info: info)
        case (.idle, .unhovered):
            return self
        // hover
        case (.hover, .unhovered):
            let info = getInfo()
            if info.isEmpty {
                return .hidden
            }
            return .idle(info: info)
        case (.hover(let info), .clicked):
            return .openHovered(info: info)
        case (.hover, .hovered):
            return self
        // hidden
        case (.hidden, .hovered):
            return .hiddenHover
        case (.hidden, .clicked):
            return .openHovered(info: [])
        case (.hidden, .unhovered):
            return self
        // open
        case (.open(let info), .hovered):
            return .openHovered(info: info)
        case (.open, .unhovered):
            return self
        case (.open(let info), .clicked):
            if info.isEmpty {
                return .hidden
            }
            return .idle(info: info)
        // hiddenHover
        case (.hiddenHover, .unhovered):
            return .hidden
        case (.hiddenHover, .clicked):
            return .openHovered(info: [])
        case (.hiddenHover, .hovered):
            return self
        // openHovered
        case (.openHovered, .hovered):
            return self
        case (.openHovered(let info), .unhovered):
            return .open(info: info)
        case (.openHovered(let info), .clicked):
            if info.isEmpty {
                return .hidden
            }
            return .idle(info: info)
        }
    }

    func getInfo() -> [Information] {
        return []
    }

    func asSize() -> NSSize {
        switch self {
        case .hidden: return Self.hiddenFrame
        case .idle: return Self.idleFrame
        case .hover: return Self.hoverFrame
        case .open(_): return Self.openFrame
        case .hiddenHover: return Self.hiddenHoverFrame
        case .openHovered: return Self.openHoveredFrame
        }
    }

    static let hiddenFrame = NSSize(width: 174, height: notch + 6)
    static let hiddenHoverFrame = NSSize(width: 190, height: notch + 6 + 6)
    static let idleFrame = NSSize(width: 256, height: notch + 6)
    static let hoverFrame = NSSize(width: 260, height: notch + 4 + 6)
    static let openFrame = NSSize(width: 260, height: notch * 2 + 6)
    static let openHoveredFrame = NSSize(width: 260 + 12, height: notch * 2 + 6 + 6)
    static let notch = 32
}

class ViewModel: ObservableObject {
    var app: AppDelegate
    @Published var sizeState: AppSizeState = .hidden {
        didSet {
            switch (oldValue, sizeState) {
            case (.hover, .idle):
                self.resizeTo(size: self.sizeState.asSize(), duration: 0.2)
                NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .now)
            case (.idle, .hover):
                self.resizeTo(size: self.sizeState.asSize(), duration: 0.2)
                NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .now)
            case (.hidden, .hiddenHover):
                self.resizeTo(size: self.sizeState.asSize(), duration: 0.2)
                NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .now)
            case (.hiddenHover, .hidden):
                self.resizeTo(size: self.sizeState.asSize(), duration: 0.2)
                NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .now)
            case (.open, .openHovered):
                self.resizeTo(size: self.sizeState.asSize(), duration: 0.2)
                NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .now)
            case (.openHovered, .open):
                self.resizeTo(size: self.sizeState.asSize(), duration: 0.2)
                NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .now)
            case (_, _):
                self.resizeTo(size: self.sizeState.asSize(), duration: 0.2)
            }
        }
    }

    func resizeTo(
        size: NSSize, easing: CAMediaTimingFunctionName = .easeOut, duration: TimeInterval = 0.15
    ) {
        let frame = {
            var frame = self.app.window.frame
            frame.size = size
            return frame.atScreenCenter()
        }
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: easing)
            self.app.window.animator().setFrame(frame(), display: true)
        })
    }

    init(app: AppDelegate) {
        self.app = app
    }

    func reduceSizeState(event: AppSizeStateEvent) {
        self.sizeState = self.sizeState.reduce(event: event)
    }
}
