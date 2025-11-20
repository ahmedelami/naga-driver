import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var configManager = ConfigManager() // Shared manager

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create Window manually
        let contentView = ContentView(manager: configManager)
            .frame(width: 800, height: 500)
            .background(Color(NSColor.windowBackgroundColor))
            
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 500),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        
        window.isReleasedWhenClosed = false 
        window.center()
        window.setFrameAutosaveName("Naga Preferences")
        window.contentView = NSHostingView(rootView: contentView)
        window.title = "Naga Preferences"
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func showWindow() {
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

@main
struct NagaConfiguratorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        MenuBarExtra("Naga", systemImage: "computermouse.fill") {
            Button("Preferences...") {
                appDelegate.showWindow()
            }
            Divider()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}
