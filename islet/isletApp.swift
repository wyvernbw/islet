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
        return true;
    }
    override var canBecomeKey: Bool {
        return true;
    }

}

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: MainNSPanel!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let viewModel = ViewModel(app: self)
        // Create the SwiftUI view
        let contentView = ContentView(viewModel: viewModel)

        // Create the borderless window
        let panel = MainNSPanel.init(
            contentRect: NSRect(x: 0, y: 0, width: 256, height: 32),
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
        self.positionWindowAtTopCenter()

    }
    
    func positionWindowAtTopCenter() {
        print(self.window.frame.origin)
        guard let screen = NSScreen.main else { return }
        print("we got screen")
        let screenFrame = screen.frame
        let windowSize = self.window.frame.size
        
        let xPos = screenFrame.origin.x + (screenFrame.width - windowSize.width) / 2
        let yPos = screenFrame.origin.y + screenFrame.height - windowSize.height
        
        self.window.setFrameOrigin(NSPoint(x: xPos, y: yPos));
        
        print(self.window.frame.origin)
    }
}

enum AppSizeStateEvent {
    case hovered
    case unhovered
}

enum AppSizeState {
    case idle
    case hover
    
    func reduce(event: AppSizeStateEvent) -> AppSizeState {
        switch (self, event) {
            case (.idle, .hovered):
                return .hover
            case(.hover, .unhovered):
                return .idle
            default:
                return self
        }
    }
}

class ViewModel: ObservableObject {
    var app: AppDelegate!;
    @Published var sizeState: AppSizeState = .idle {
        didSet {
            print("sizeState changed from \(oldValue) to \(sizeState)")
        }
    }

    init(app: AppDelegate) {
        self.app = app
    }

    func reduceSizeState(event: AppSizeStateEvent) {
        self.sizeState = self.sizeState.reduce(event: event)
    }
}
