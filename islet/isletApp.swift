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
}

enum Information {

}

enum AppSizeState {
    case hidden
    case idle(
        info: [Information]
    )
    case hover

    func reduce(event: AppSizeStateEvent) -> AppSizeState {
        switch (self, event) {
        case (.idle, .hovered):
            return .hover
        case (.hover, .unhovered):
            let info = getInfo()
            if info.isEmpty {
                return .hidden
            }
            return .idle(info: info)
        case (_, .unhovered):
            fatalError("unreachable")
        case (.hidden, .hovered):
            return .hover
        case (.hover, .hovered):
            fatalError("unreachable")
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
        }
    }

    static let hiddenFrame = NSSize(width: 174, height: notch + 6)
    static let idleFrame = NSSize(width: 256, height: notch + 6)
    static let hoverFrame = NSSize(width: 260, height: notch + 4 + 6)
    static let notch = 32
}

class ViewModel: ObservableObject {
    var app: AppDelegate
    @Published var sizeState: AppSizeState = .hidden {
        didSet {
            switch (oldValue, sizeState) {
            case (_, .hover):
                self.resizeTo(size: AppSizeState.hoverFrame)
                NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .now)
            case (.hover, .idle):
                self.resizeTo(size: AppSizeState.idleFrame, duration: 0.2)
                NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .now)
            case (.idle, .hidden):
                self.resizeTo(size: AppSizeState.hiddenFrame, duration: 0.2)
            case (.hidden, .idle):
                self.resizeTo(size: AppSizeState.hiddenFrame, duration: 0.2)
            case (.hover, .hidden):
                self.resizeTo(size: AppSizeState.hiddenFrame, duration: 0.2)
                NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .now)
            case (.idle, .idle):
                break
            case (.hidden, .hidden):
                break
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
