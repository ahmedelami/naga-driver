import Foundation

struct KarabinerConfig: Codable {
    var title: String
    var rules: [KarabinerRule]
}

struct KarabinerRule: Codable {
    var description: String
    var manipulators: [KarabinerManipulator]
}

struct KarabinerManipulator: Codable {
    var type: String = "basic"
    var from: KarabinerFrom
    var to: [KarabinerTo]
    var conditions: [KarabinerCondition]?
}

struct KarabinerFrom: Codable {
    var key_code: String
    var modifiers: KarabinerModifiers?
}

struct KarabinerModifiers: Codable {
    var optional: [String] = ["any"]
}

struct KarabinerTo: Codable {
    var key_code: String?
    var modifiers: [String]?
    // Add shell_command if we want to support that later
}

struct KarabinerCondition: Codable {
    var type: String = "device_if"
    var identifiers: [KarabinerIdentifier]
}

struct KarabinerIdentifier: Codable {
    var vendor_id: Int?
    var product_id: Int?
    var is_keyboard: Bool?
    var is_mouse: Bool?
}