//
//  Configuration.swift
//  Commander
//
//  Created by 张行 on 2019/10/26.
//

import Foundation

public enum MirrorError : Error {
    case systemError
}

func localMirrorPath() throws -> String {
    #if os(macOS)
    return "/Users/$USER"
    #elseif os(Linux)
    return "/home/$USER"
    #else
    throw MirrorError.systemError
    #endif
}

let dependencies:[String] = []
