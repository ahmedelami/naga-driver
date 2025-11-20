import Cocoa

let eventMask = (1 << CGEventType.keyDown.rawValue) | 
                (1 << CGEventType.flagsChanged.rawValue)

func log(_ msg: String) {
    print(msg)
    fflush(stdout)
}

guard let eventTap = CGEvent.tapCreate(
    tap: .cghidEventTap, // Highest tap point
    place: .headInsertEventTap,
    options: .defaultTap,
    eventsOfInterest: CGEventMask(eventMask),
    callback: { proxy, type, event, refcon in
        
        if type == .flagsChanged {
            let code = event.getIntegerValueField(.keyboardEventKeycode)
            let flags = event.flags.rawValue
            log("🚩 FLAGS CHANGED: Code=\(code) Flags=\(flags)")
        }
        else if type == .keyDown {
            let code = event.getIntegerValueField(.keyboardEventKeycode)
            log("⌨️ KEY DOWN: Code=\(code)")
        }
        
        return Unmanaged.passUnretained(event)
    },
    userInfo: nil
) else {
    log("❌ Failed to create Event Tap (Check Permissions)")
    exit(1)
}

let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
CGEvent.tapEnable(tap: eventTap, enable: true)

log("🟢 LISTENING... Press 'Fn' now.")
CFRunLoopRun()
