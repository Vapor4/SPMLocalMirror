import Commander
import Foundation
import SwiftShell


Group { (g) in
    g.command(
        "local",
        Option<String>("path", default: "PWD", description: "Package.swift所在文件夹路径"),
        Option<String>("type", default: "build", description: "执行的类型默认为build 相当于swift build, xcode 相当于swift package generate-xcodeproj")
    ) { path, type in
        // 获取当前当前路径
        guard var pwd = CustomContext(main).env["PWD"] else {
            print("‼️PWD获取当前路径错误")
            return
        }
        if path != "PWD" {
            pwd = path
        }
        // 获取Package.swift路径
        var packagePath = "\(pwd)/Package.swift"
        let mirrorPath = "\(pwd)/Package.mirror"
        let isExitMirror = FileManager.default.fileExists(atPath: "\(mirrorPath)")
        if isExitMirror {
            packagePath = mirrorPath
        }
        // 查询当前用户名称
        guard let user = ShellCommand.getUser() else {
            print("‼️查询不到用户信息")
            return
        }
        // 本地镜像的路径
        let localPath = "\(try localMirrorPath(user))/SPMLocalMirror"
        ShellCommand.createDirectory(path: localPath)
        // 临时缓存目录
        let cachePath = "\(localPath)/Cache"
        // 如果之前存在 就移除之前的缓存
        if FileManager.default.fileExists(atPath: cachePath) {
            try FileManager.default.removeItem(atPath: cachePath)
        }
        ShellCommand.createDirectory(path: cachePath)
        // 网络源目录
        let sourcePath = "\(localPath)/Source"
        ShellCommand.createDirectory(path: sourcePath)
        
        let packageManager = PackageManager()
        try packageManager.changeLocalPackage(localPath, pwd)
        main.currentdirectory = pwd
        if type == "build" {
            // swift build
            try runAndPrint("swift", "build")
        } else if type == "xcode" {
            // swift package generate-xcodeproj
            try runAndPrint("swift", "package", "generate-xcodeproj")
        }
    }
}.run()



