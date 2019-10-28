//
//  ShellCommand.swift
//  SPMLocalMirror
//
//  Created by 张行 on 2019/10/28.
//

import Foundation
import SwiftShell

struct ShellCommand {
    static func createDirectory(path:String) {
        if (!FileManager.default.fileExists(atPath: path, isDirectory: nil)) {
            print("mkdir \(path)")
            try? runAndPrint("mkdir", path)
        }
    }
    
    static func getUser() -> String? {
        let cleanctx = CustomContext(main)
        return cleanctx.env["USER"]
    }
    
    
}
