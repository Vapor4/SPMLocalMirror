import Commander
import Foundation
import SwiftShell


Group { (g) in
    g.command(
        "local",
        Argument<String>("package", description: "请输入本地Package.swift所在的路径地址")
    ) { package in
        if package.contains("http") {
            print("🔴 只支持本地的路径")
            return
        }
        let packagePath = "\(package)/Package.swift"
        let packageManager = PackageManager()
        let content = try packageManager.loadContent(packagePath)
        try packageManager.appenURLInDependencies(content)
        // 创建目录
        guard let user = ShellCommand.getUser() else {
            print("查询不到用户信息")
            return
        }
        let localPath = "\(try localMirrorPath(user))/SPMLocalMirror"
        ShellCommand.createDirectory(path: localPath)
        // 创建临时缓存目录
        let cachePath = "\(localPath)/Cache"
        if FileManager.default.fileExists(atPath: cachePath) {
            try FileManager.default.removeItem(atPath: cachePath)
        }
        ShellCommand.createDirectory(path: cachePath)
        // 创建源目录
        let sourcePath = "\(localPath)/Source"
        ShellCommand.createDirectory(path: sourcePath)
        
        // 设置目录为源目录 更新源或者下载
        for content in dependencies {
            if !content.url.contains("http") {
                // 如果就是本地的依赖 则不需要任何的操作
                continue
            }
            main.currentdirectory = sourcePath
            let groupItems = content.url.groupItems()
            let groupPath = "\(sourcePath)/\(groupItems[groupItems.count - 2])"
            ShellCommand.createDirectory(path: groupPath)
            let itemPath = "\(groupPath)/\(groupItems[groupItems.count - 1])"
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
        try packageManager.changeLocalPackage(localPath, package)
    }
}.run()



