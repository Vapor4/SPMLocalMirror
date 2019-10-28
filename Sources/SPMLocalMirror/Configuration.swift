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

func localMirrorPath(_ user:String) throws -> String {
    #if os(macOS)
    return "/Users/\(user)"
    #elseif os(Linux)
    return "/home/\(user)"
    #else
    throw MirrorError.systemError
    #endif
}

var dependencies:[DependenciesManager.Content] = []
