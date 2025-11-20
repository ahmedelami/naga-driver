import Cocoa

let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.flagsChanged.rawValue)

guard let eventTap = CGEvent.tapCreate(
    tap: .cghidEventTap,
    place: .headInsertEventTap,
    options: .defaultTap,
    eventsOfInterest: CGEventMask(eventMask),
    callback: { proxy, type, event, refcon in
        if type == .flagsChanged {
            let code = event.getIntegerValueField(.keyboardEventKeycode)
            let flags = event.flags.rawValue
            print("FLAGS CHANGED: Code=\(code) Flags=\(flags)")
            fflush(stdout)
        }
        return Unmanaged.passUnretained(event)
    },
    userInfo: nil
) else {
    print("Failed to create event tap")
    exit(1)
}

let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
CGEvent.tapEnable(tap: eventTap, enable: true)
print("READY. Press Fn.")
fflush(stdout)
CFRunLoopRun()
