import Foundation

// Internal UI Model
struct Mapping: Codable, Identifiable, Hashable {
    var id = UUID()
    var type: String // "shortcut"
    var key: String?
    var modifiers: [String]?
    
    // Legacy fields
    var path: String?
    var args: [String]?
    var duration: Double?
}

class ConfigManager: ObservableObject {
    @Published var mappings: [String: [Mapping]] = [: ]
    
    // Main Karabiner Config File
    private let karabinerConfigURL = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".config/karabiner/karabiner.json")
    
    init() {
        load()
    }
    
    func load() {
        if let data = UserDefaults.standard.data(forKey: "NagaMappings"),
           let decoded = try? JSONDecoder().decode([String: [Mapping]].self, from: data) {
            self.mappings = decoded
        }
    }
    
    func save() {
        // 1. Save UI State
        if let data = try? JSONEncoder().encode(mappings) {
            UserDefaults.standard.set(data, forKey: "NagaMappings")
        }
        
        // 2. Generate Rules
        let newRules = generateKarabinerRules()
        
        // 3. Inject into Karabiner Config
        updateKarabinerConfig(with: newRules)
    }
    
    private func updateKarabinerConfig(with newRules: [KarabinerRule]) {
        guard let data = try? Data(contentsOf: karabinerConfigURL),
              var json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            print("❌ Could not read karabiner.json")
            return
        }
        
        guard var profiles = json["profiles"] as? [[String: Any]], !profiles.isEmpty else { return }
        
        var profileIndex = 0
        for (i, p) in profiles.enumerated() {
            if let selected = p["selected"] as? Bool, selected {
                profileIndex = i
                break
            }
        }
        var profile = profiles[profileIndex]
        
        var complex = profile["complex_modifications"] as? [String: Any] ?? [:]
        var rules = complex["rules"] as? [[String: Any]] ?? []
        
        // Remove old Naga rules
        rules.removeAll { rule in
            let desc = rule["description"] as? String ?? ""
            return desc.starts(with: "Naga Button") || desc == "Naga Controller Rules"
        }
        
        // Add new rules
        if let ruleData = try? JSONEncoder().encode(newRules),
           let ruleDicts = try? JSONSerialization.jsonObject(with: ruleData, options: []) as? [[String: Any]] {
            rules.append(contentsOf: ruleDicts)
        }
        
        complex["rules"] = rules
        profile["complex_modifications"] = complex
        profiles[profileIndex] = profile
        json["profiles"] = profiles
        
        if let finalData = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .withoutEscapingSlashes]) {
            try? finalData.write(to: karabinerConfigURL)
            print("✅ Updated karabiner.json")
        }
    }
    
    private func generateKarabinerRules() -> [KarabinerRule] {
        var rules: [KarabinerRule] = []
        
        let condition = KarabinerCondition(type: "device_if", identifiers: [
            KarabinerIdentifier(vendor_id: 5426), // Razer
            KarabinerIdentifier(vendor_id: 5758),
            KarabinerIdentifier(vendor_id: 1678)
        ])
        
        let sortedKeys = mappings.keys.sorted { (a, b) -> Bool in
            return (Int(a) ?? 0) < (Int(b) ?? 0)
        }
        
        for btn in sortedKeys {
            guard let actions = mappings[btn] else { continue }
            let fromKey = mapButtonToKey(btn)
            var toEvents: [KarabinerTo] = []
            
            for action in actions {
                if action.type == "shortcut", let k = action.key {
                    let code = mapInternalKeyToKarabiner(k)
                    let mods = action.modifiers?.map { mapModifier($0) }
                    toEvents.append(KarabinerTo(key_code: code, modifiers: mods))
                }
            }
            
            if !toEvents.isEmpty {
                let manipulator = KarabinerManipulator(
                    from: KarabinerFrom(key_code: fromKey, modifiers: KarabinerModifiers()),
                    to: toEvents,
                    conditions: [condition]
                )
                rules.append(KarabinerRule(description: "Naga Button \(btn)", manipulators: [manipulator]))
            }
        }
        return rules
    }
    
    private func mapButtonToKey(_ btn: String) -> String {
        switch btn {
        case "1": return "1"; case "2": return "2"; case "3": return "3"; case "4": return "4";
        case "5": return "5"; case "6": return "6"; case "7": return "7"; case "8": return "8";
        case "9": return "9"; case "10": return "0"; case "11": return "hyphen"; case "12": return "equal_sign";
        default: return "1"
        }
    }
    
    private func mapModifier(_ mod: String) -> String {
        switch mod {
        case "cmd": return "left_command"
        case "opt": return "left_option"
        case "ctrl": return "left_control"
        case "shift": return "left_shift"
        case "fn": return "fn"
        default: return "left_command"
        }
    }
    
    private func mapInternalKeyToKarabiner(_ key: String) -> String {
        switch key.lowercased() {
        case "left": return "left_arrow"
        case "right": return "right_arrow"
        case "up": return "up_arrow"
        case "down": return "down_arrow"
        case "cmd", "command": return "left_command"
        case "esc": return "escape"
        case "return", "enter": return "return_or_enter"
        case "leftbracket", "[": return "open_bracket"
        case "rightbracket", "]": return "close_bracket"
        case "minus", "-": return "hyphen"
        case "equal", "=": return "equal_sign"
        case "quote", "'": return "quote"
        case "semicolon", ";": return "semicolon"
        case "comma", ",": return "comma"
        case "period", ".": return "period"
        case "slash", "/": return "slash"
        case "backslash", "\\": return "backslash"
        default: return key
        }
    }
}
