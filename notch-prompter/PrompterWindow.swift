import AppKit
import SwiftUI

final class PrompterWindow {
    private var window: NSWindow!
    private let viewModel: PrompterViewModel

    init(viewModel: PrompterViewModel) {
        self.viewModel = viewModel

        let contentView = PrompterView(viewModel: viewModel)
            .frame(width: 800, height: 150)

        let hosting = NSHostingView(rootView: contentView)
        hosting.wantsLayer = true
        hosting.layer?.cornerRadius = 16
        hosting.layer?.masksToBounds = true

        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 150),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .floating
        window.hasShadow = true
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.isMovableByWindowBackground = false
        window.contentView = hosting
    }

    func show() {
        guard let screen = NSScreen.main else {
            window.center()
            window.makeKeyAndOrderFront(nil)
            return
        }

        // Position top-center of the main screen
        let screenFrame = screen.visibleFrame
        let windowSize = window.frame.size
        let x = screenFrame.midX - windowSize.width / 2
        // place near the top, with a small margin
        let y = screenFrame.maxY - windowSize.height - 20
        window.setFrameOrigin(NSPoint(x: x, y: y))

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
