// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 16/05/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

public struct Platform {
        public static func currentPlatform() -> String {
            #if os(macOS)
            return "macOS"
            #elseif os(iOS)
            return "iOS"
            #elseif os(Linux)
            return "linux"
            #else
            return "unknown"
            #endif
        }
}
