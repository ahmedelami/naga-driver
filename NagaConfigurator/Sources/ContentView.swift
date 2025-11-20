import SwiftUI
import Carbon

struct ContentView: View {
    @ObservedObject var manager: ConfigManager
    @State private var selectedButton: String?
    @State private var showResetConfirm = false 
    
    let columns = [
        GridItem(.flexible()), 
        GridItem(.flexible()), 
        GridItem(.flexible())
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            VStack {
                Text("Naga V2 HS")
                    .font(.headline)
                    .padding(.top)
                
                Button("Reset All Mappings") {
                    showResetConfirm = true
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .tint(.red)
                .confirmationDialog("Are you sure you want to clear all mappings?", isPresented: $showResetConfirm) {
                    Button("Reset All", role: .destructive) {
                        manager.mappings = [:]
                        manager.save()
                    }
                    Button("Cancel", role: .cancel) { }
                }
                
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(1...12, id: \.self) { i in
                        Button(action: { selectedButton = String(i) }) {
                            VStack {
                                Text("\(i)")
                                    .font(.title)
                                    .frame(width: 40, height: 25)
                                
                                if let actions = manager.mappings[String(i)], !actions.isEmpty {
                                    Text(summary(for: actions))
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                } else {
                                    Text("Unmapped")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .frame(width: 70, height: 60)
                            .background(selectedButton == String(i) ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedButton == String(i) ? Color.accentColor : Color.clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
                Spacer()
            }
            .frame(width: 280)
            
            VStack {
                if let btn = selectedButton {
                    EditorView(buttonIndex: btn, manager: manager)
                } else {
                    Text("Select a button to edit")
                        .foregroundColor(.secondary)
                }
            }
            .frame(minWidth: 400)
        }
    }
    
    func summary(for actions: [Mapping]) -> String {
        if actions.isEmpty { return "Unmapped" }
        let first = actions[0]
        if first.type == "shortcut" {
            let mods = first.modifiers?.map { $0 == "cmd" ? "⌘" : $0 }.joined() ?? ""
            let key = first.key?.uppercased() ?? ""
            return actions.count > 1 ? "\(mods)\(key)..." : "\(mods)\(key)"
        }
        return first.type.capitalized
    }
}

struct EditorView: View {
    let buttonIndex: String
    @ObservedObject var manager: ConfigManager
    @State private var isRecording = false
    @State private var showSavedMessage = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Button \(buttonIndex)")
                    .font(.largeTitle)
                Spacer()
                if showSavedMessage {
                    Text("Saved ✓")
                        .foregroundColor(.green)
                        .transition(.opacity)
                }
            }
            .padding()
            
            List {
                let actions = manager.mappings[buttonIndex] ?? []
                ForEach(Array(actions.enumerated()), id: \.offset) { index, mapping in
                    HStack {
                        Text("\(index + 1).")
                            .foregroundColor(.secondary)
                            .frame(width: 20)
                        
                        if mapping.type == "shortcut" {
                            Image(systemName: "keyboard")
                            Text((mapping.modifiers?.map { formatMod($0) }.joined() ?? "") + (mapping.key?.uppercased() ?? ""))
                                .fontWeight(.bold)
                                .font(.system(.body, design: .monospaced))
                        }
                        
                        Spacer()
                        Button(action: { deleteAction(at: index) }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(4)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(6)
                }
            }
            
            Divider()
            
            VStack(spacing: 10) {
                if isRecording {
                    VStack {
                        HStack {
                            Image(systemName: "record.circle.fill")
                                .foregroundColor(.red)
                                .font(.title)
                            Text("Press keys... (Esc to finish)")
                                .font(.title2)
                                .foregroundColor(.red)
                        }
                        
                        Button("Stop Recording") {
                            stopRecording()
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
                    .onAppear { startMonitoring() }
                    .onDisappear { stopMonitoring() }
                } else {
                    HStack(spacing: 10) {
                        Button(action: { isRecording = true }) {
                            HStack {
                                Image(systemName: "record.circle")
                                Text("Record Macro")
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 32)
                            .background(Color.accentColor.opacity(0.1))
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: { addShortcut(key: "fn", modifiers: []) }) {
                            HStack {
                                Image(systemName: "globe")
                                Text("Add Fn")
                            }
                            .frame(width: 100)
                            .frame(height: 32)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.blue)
                        
                        Button(action: { clearButton() }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Clear")
                            }
                            .frame(width: 100)
                            .frame(height: 32)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.red)
                    }
                }
            }
            .padding()
        }
    }
    
    // --- Actions ---
    
    func addShortcut(key: String, modifiers: [String]) {
        var current = manager.mappings[buttonIndex] ?? []
        current.append(Mapping(type: "shortcut", key: key, modifiers: modifiers, path: nil, args: nil, duration: nil))
        manager.mappings[buttonIndex] = current
        
        // Auto Save immediately for buttons
        manager.save()
    }
    
    func deleteAction(at index: Int) {
        var current = manager.mappings[buttonIndex] ?? []
        current.remove(at: index)
        manager.mappings[buttonIndex] = current
        triggerSave()
    }
    
    func triggerSave() {
        manager.save()
        withAnimation { showSavedMessage = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showSavedMessage = false }
        }
    }
    
    func stopRecording() {
        isRecording = false
        triggerSave()
    }
    
    func clearButton() {
        manager.mappings[buttonIndex] = []
        triggerSave()
    }
    
    func formatMod(_ mod: String) -> String {
        switch mod {
        case "cmd": return "⌘"
        case "shift": return "⇧"
        case "opt": return "⌥"
        case "ctrl": return "⌃"
        case "fn": return "Fn"
        default: return ""
        }
    }
    
    // --- Key Monitoring ---
    
    @State private var localMonitor: Any?
    @State private var globalMonitor: Any?

    func startMonitoring() {
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { event in
            print("LOCAL: \(event.keyCode)")
            if event.type == .flagsChanged {
                handleFlags(event)
            } else {
                handleKey(event)
            }
            return nil 
        }
        
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { event in
            print("GLOBAL: \(event.keyCode)")
            if event.type == .flagsChanged {
                handleFlags(event)
            } else {
                handleKey(event)
            }
        }
    }
    
    func stopMonitoring() {
        if let m = localMonitor { NSEvent.removeMonitor(m); localMonitor = nil }
        if let m = globalMonitor { NSEvent.removeMonitor(m); globalMonitor = nil }
    }
    
    func handleFlags(_ event: NSEvent) {
        if event.keyCode == 63 || event.keyCode == 179 || event.modifierFlags.contains(.function) {
            // Only record on Press (if flags contain function)
            if event.modifierFlags.contains(.function) {
                 let modifiers = getModifiers(event.modifierFlags.subtracting(.function))
                 print("Recording Fn")
                 addShortcut(key: "fn", modifiers: modifiers)
                 // Stop after Fn? Usually Fn is a modifier, but here treating as key.
                 // Don't stop, maybe they want Fn+F1.
            }
        }
    }
    
    func handleKey(_ event: NSEvent) {
        if event.keyCode == 53 { // Esc
            stopRecording()
            return
        }
        
        let key = getKeyString(keyCode: event.keyCode)
        let modifiers = getModifiers(event.modifierFlags)
        
        if !key.isEmpty {
            addShortcut(key: key, modifiers: modifiers)
        }
    }
    
    func getKeyString(keyCode: UInt16) -> String {
        switch keyCode {
        case 0: return "a"; case 1: return "s"; case 2: return "d"; case 3: return "f"; case 4: return "h"; case 5: return "g";
        case 6: return "z"; case 7: return "x"; case 8: return "c"; case 9: return "v"; case 11: return "b"; case 12: return "q";
        case 13: return "w"; case 14: return "e"; case 15: return "r"; case 16: return "y"; case 17: return "t"; case 18: return "1";
        case 19: return "2"; case 20: return "3"; case 21: return "4"; case 23: return "5"; case 22: return "6"; case 26: return "7";
        case 28: return "8"; case 25: return "9"; case 29: return "0"; 
        case 27: return "minus"; case 24: return "equal"; 
        case 33: return "leftbracket"; case 30: return "rightbracket";
        case 43: return "comma"; case 47: return "period"; case 44: return "slash"; 
        case 41: return "semicolon"; case 39: return "quote"; case 42: return "backslash"; case 50: return "grave";
        
        case 36: return "enter"; case 49: return "space"; case 48: return "tab"; case 51: return "backspace";
        
        case 123: return "left"; case 124: return "right"; case 125: return "down"; case 126: return "up";
        
        case 122: return "f1"; case 120: return "f2"; case 99: return "f3"; case 118: return "f4";
        case 96: return "f5"; case 97: return "f6"; case 98: return "f7"; case 100: return "f8";
        case 101: return "f9"; case 109: return "f10"; case 103: return "f11"; case 111: return "f12";
        
        case 179, 63: return "fn";
        
        case 55, 56, 57, 58, 59, 60, 61, 62, 63: return ""
        default: return "unknown(\(keyCode))"
        }
    }
    
    func getModifiers(_ flags: NSEvent.ModifierFlags) -> [String] {
        var mods: [String] = []
        if flags.contains(.command) { mods.append("cmd") }
        if flags.contains(.shift) { mods.append("shift") }
        if flags.contains(.option) { mods.append("opt") }
        if flags.contains(.control) { mods.append("ctrl") }
        if flags.contains(.function) { mods.append("fn") }
        return mods
    }
}
