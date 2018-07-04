// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 04/07/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

struct SemanticVersion: Equatable, Comparable {
    let major: Int
    let minor: Int
    let patch: Int

    init(major: Int, minor: Int, patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }
    
    init?(major: String, minor: String, patch: String) {
        guard let iMajor = Int(major), let iMinor = Int(minor), let iPatch = Int(patch) else {
            return nil
        }

        self.major = iMajor
        self.minor = iMinor
        self.patch = iPatch
    }

    var text: String {
        return patch == 0 ? "\(major).\(minor)" : "\(major).\(minor).\(patch)"
    }

}

func <(x: SemanticVersion, y: SemanticVersion) -> Bool {
    if (x.major < y.major) {
        return true
    } else if (x.major > y.major) {
        return false
    } else if (x.minor < y.minor) {
        return true
    } else if (x.minor > y.minor) {
        return false
    } else {
        return x.patch < y.patch
    }

}
