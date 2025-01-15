//
//  SwipeSimulator.swift
//  SaneSideButtons
//
//  Created by Jan Hülsmann on 16.10.22.
//

import AppKit

final class SwipeSimulator {

    private enum Keys {
        static let ignored: String = "ignoredApplications"
        static let reverse: String = "reverseButtons"
    }

    static let shared = SwipeSimulator()
    private(set) var eventTapIsRunning: Bool = false
    private(set) var ignoredApplications: [String] = UserDefaults.standard.stringArray(forKey: Keys.ignored) ?? [] {
        didSet {
            UserDefaults.standard.set(self.ignoredApplications, forKey: Keys.ignored)
        }
    }
    var reverseButtons: Bool = UserDefaults.standard.bool(forKey: Keys.reverse) {
        didSet {
            UserDefaults.standard.set(self.reverseButtons, forKey: Keys.ignored)
        }
    }

    private let swipeBegin = [
        kTLInfoKeyGestureSubtype: kTLInfoSubtypeSwipe,
        kTLInfoKeyGesturePhase: 1
    ]

    private let swipeLeft = [
        kTLInfoKeyGestureSubtype: kTLInfoSubtypeSwipe,
        kTLInfoKeySwipeDirection: kTLInfoSwipeLeft,
        kTLInfoKeyGesturePhase: 4
    ]

    private let swipeRight = [
        kTLInfoKeyGestureSubtype: kTLInfoSubtypeSwipe,
        kTLInfoKeySwipeDirection: kTLInfoSwipeRight,
        kTLInfoKeyGesturePhase: 4
    ]

    enum EventTap: Error {
        case failedSetup
    }

    private init() { }

    func addIgnoredApplication(bundleID: String) {
        self.ignoredApplications.append(bundleID)
    }

    func removeIgnoredApplication(bundleID: String) {
        self.ignoredApplications.removeAll { $0 == bundleID }
    }

    private func isValidApplication() -> Bool {
        guard let frontAppBundleID = NSWorkspace.shared.frontmostApplication?.bundleIdentifier else { return true }
        return !ignoredApplications.contains(frontAppBundleID)
    }

    private let eventTypes: [CGEventType] = [
        .otherMouseDown,
        .otherMouseUp,
    ]

    func setupEventTap() throws {
        guard !self.eventTapIsRunning else { return }
        guard let eventTap = CGEvent.tapCreate(tap: .cghidEventTap,
                                               place: .headInsertEventTap,
                                               options: .defaultTap,
                                               eventsOfInterest: .from(events: eventTypes),
                                               callback: mouseEventCallBack,
                                               userInfo: nil) else {
            self.eventTapIsRunning = false
            throw EventTap.failedSetup
        }
        let runLoopSource = CFMachPortCreateRunLoopSource(nil, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
        self.eventTapIsRunning = true
    }

    private func fakeSwipe(direction: TLInfoSwipeDirection, proxy: CGEventTapProxy) {
        let eventBegin: CGEvent = tl_CGEventCreateFromGesture(self.swipeBegin as CFDictionary,
                                                              [] as CFArray).takeRetainedValue()

        let swipeDirection = self.reverseButtons ? direction.reversed : direction
        let eventSwipe: CGEvent? = switch swipeDirection {
        case TLInfoSwipeDirection(kTLInfoSwipeLeft):
            tl_CGEventCreateFromGesture(self.swipeLeft as CFDictionary, [] as CFArray).takeRetainedValue()
        case TLInfoSwipeDirection(kTLInfoSwipeRight):
            tl_CGEventCreateFromGesture(self.swipeRight as CFDictionary, [] as CFArray).takeRetainedValue()
        default:
            nil
        }

        guard let eventSwipe else { return }
        eventBegin.tapPostEvent(proxy)
        eventSwipe.tapPostEvent(proxy)
    }

    private var debounceWorkItem: DispatchWorkItem?

    fileprivate func handleMouseEvent(type: CGEventType, cgEvent: CGEvent, proxy: CGEventTapProxy) -> CGEvent? {

        debounceWorkItem?.cancel()

        guard type == .otherMouseDown && self.isValidApplication() else {
            return cgEvent
        }

        let number = CGEvent.getIntegerValueField(cgEvent)(.mouseEventButtonNumber)

        let workItem = DispatchWorkItem { [weak self, cgEvent] in
            guard let self else { return }
            switch number {
                case 3:
                    fakeSwipe(direction: TLInfoSwipeDirection(kTLInfoSwipeLeft), proxy: proxy)
                case 4:
                    fakeSwipe(direction: TLInfoSwipeDirection(kTLInfoSwipeRight), proxy: proxy)
                default:
                    cgEvent.tapPostEvent(proxy)
            }
        }

        debounceWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(30), execute: workItem)
        return nil
    }
}

// swiftlint:disable private_over_fileprivate
fileprivate func mouseEventCallBack(proxy: CGEventTapProxy,
                                    type: CGEventType,
                                    cgEvent: CGEvent,
                                    userInfo: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    guard let cgEvent = SwipeSimulator.shared.handleMouseEvent(type: type, cgEvent: cgEvent, proxy: proxy) else { return nil }
    return Unmanaged.passRetained(cgEvent)
}

fileprivate extension TLInfoSwipeDirection {
    var reversed: TLInfoSwipeDirection {
        switch self {
        case TLInfoSwipeDirection(kTLInfoSwipeLeft):
            return TLInfoSwipeDirection(kTLInfoSwipeRight)
        case TLInfoSwipeDirection(kTLInfoSwipeRight):
            return TLInfoSwipeDirection(kTLInfoSwipeLeft)
        default:
            return self
        }
    }
}
// swiftlint:enable private_over_fileprivate

private extension CGEventMask {

    static func from(events: [CGEventType]) -> CGEventMask {
        events.reduce(0) { $0 | (1 << $1.rawValue) }
    }
}
