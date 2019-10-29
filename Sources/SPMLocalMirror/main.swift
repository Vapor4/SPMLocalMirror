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
        let packageManager = PackageManager()
        // 获取Package.swift内容
        let content = try packageManager.loadContent(packagePath)
        // 查询所有的依赖
        try packageManager.appenURLInDependencies(content)
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
        
        for content in dependencies {
            let isURLDependencies = try content.url.isURLDependencies()
            if !isURLDependencies {
                // 如果就是本地的依赖 则不需要任何的操作
                continue
            }
            // 设置当前终端的目录为源目录
            main.currentdirectory = sourcePath
            let groupItems = content.url.groupItems()
            // 用户名或者组织
            let groupPath = "\(sourcePath)/\(groupItems[groupItems.count - 2])"
            ShellCommand.createDirectory(path: groupPath)
            // 源的名称
            let itemPath = "\(groupPath)/\(groupItems[groupItems.count - 1])"
            // 是否存在依赖源 如果不存在就clone 否则就更新
            if !FileManager.default.fileExists(atPath: itemPath, isDirectory: nil) {
                // 没有存在 就 git clone
                main.currentdirectory = groupPath
                try runAndPrint("git", "clone", content.url)
            } else {
                // 存在就 git pull
                main.currentdirectory = itemPath
                try runAndPrint("git", "pull")
            }
            
        }
        // 更改依赖的Package.swift的内容
        try packageManager.changeLocalPackage(localPath, pwd)
        main.currentdirectory = pwd
        if type == "build" {
            // swift build
            try runAndPrint("swift", "build")
        } else if type == "xcode" {
            // swift package generate-xcodeproj
            try runAndPrint("swift", "package", "generate-xcodeproj")
        }
        try content.write(toFile: "\(pwd)/Package.swift", atomically: true, encoding: String.Encoding.utf8)
    }
}.run()



