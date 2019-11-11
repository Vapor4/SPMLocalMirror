//
//  PackageManager.swift
//  SPMLocalMirror
//
//  Created by 张行 on 2019/10/26.
//

import Foundation
import SwiftShell

struct PackageManager {
    func loadContent(_ s:String) throws -> String {
        print("正在分析依赖：\(s)")
        let url:URL
        if try isURLDependencies(s) {
            guard let _url = URL(string: s) else {
                throw MirrorError.systemError
            }
            url = _url
        } else {
            url = URL(fileURLWithPath: s)
        }
        let data = try Data(contentsOf: url)
        let result = String(data: data, encoding: String.Encoding.utf8)
        guard let _result = result else {
            throw MirrorError.systemError
        }
        return _result
    }
    
    func isURLDependencies(_ s:String) throws -> Bool {
        return try s.regMatches(#"http[s]*:"#).count > 0
    }
    
    func appenURLInDependencies(_ content:String, _ cachePath:String) throws {
        let dependenciesManager = DependenciesManager(content: content)
        let contents = try dependenciesManager.contents(cachePath)
        for content in contents {
            print("依赖: \(content.url)")
            if !isExitDependencies(content) {
                dependencies.append(content)
            }
            if let _ = content.requirement {
                let name = content.url.groupName()
                let subPackageURL = "https://raw.githubusercontent.com/\(name)/master/Package.swift"
                let subContent = try loadContent(subPackageURL)
                try appenURLInDependencies(subContent, cachePath)
            }
        }
    }
    
    func isExitDependencies(_ content:DependenciesManager.Content) -> Bool {
        for c in dependencies {
            if c.url == content.url {
                return true
            }
        }
        return false
    }
    
    func changeLocalPackage(_ rootPath:String ,_ packageDirectory:String) throws {
        // 获取缓存的目录
        let cachePath = "\(rootPath)/Cache"
        let sourcePath = "\(rootPath)/Source"
        // 获取依赖的Package.swift文件路径
        var packagePath = "\(packageDirectory)/Package.swift"
        let mirrorPath = "\(packageDirectory)/Package.mirror"
        let isExitMirror = FileManager.default.fileExists(atPath: mirrorPath)
        if isExitMirror {
            packagePath = mirrorPath
        }
        // 加载Package.swift文件内容
        let packageContent = try loadContent(packagePath)
        // 替换的内容
        var replaceContent:String = """
        [
        """
        let manager = DependenciesManager(content: packageContent)
        // 默认是拿到所有的依赖
        let contents:[DependenciesManager.Content] = try manager.contents(cachePath)
        for content in contents {
            let items = content.url.groupItems()
            let groupName = content.url.groupName()
            let groupPath = "\(cachePath)/\(items[items.count - 2])"
            let sourceGroupPath = "\(sourcePath)/\(items[items.count - 2])"
            ShellCommand.createDirectory(path: groupPath)
            ShellCommand.createDirectory(path: sourceGroupPath)
            // 如果是我们不支持的类型 则放弃
            guard let req = content.requirement else {
                replaceContent += """
                
                .package(path: "\(content.url)"),
                """
                continue
            }
            // Checkout 下来的名称
            let checkOutName:String
            // Clone源的路径地址
            let clonePath = "\(rootPath)/Source/\(groupName)"
            if !FileManager.default.fileExists(atPath: clonePath) {
                print("\(clonePath)不存在")
                // 如果不存在
                main.currentdirectory = sourceGroupPath
                try runAndPrint("git", "clone", content.url)
            }
            main.currentdirectory = clonePath
            // 获取所有的源支持的Tag
            let tagOutput = run("git", "tag")
            let tags = tagOutput.stdout.components(separatedBy: "\n")
            if let range = req.range, range.count > 0 {
                var _tempTag = ""
                for tag in tags {
                    if tag > _tempTag && tag >= range[0].lowerBound && tag < range[0].upperBound {
                        _tempTag = tag
                    }
                }
                checkOutName = _tempTag
            } else if let exact = req.exact, exact.count > 0 {
                checkOutName = exact[0]
            } else if let branch = req.branch, branch.count > 0 {
                checkOutName = branch[0]
            } else if let revision = req.revision, revision.count > 0 {
                checkOutName = revision[0]
            } else {
                print("未知类型 请联系作者")
                throw MirrorError.systemError
            }
            
            // 需要替换的本地路径
            let localPath = "\(cachePath)/\(groupName)"
            replaceContent += """
            
                    .package(path: "\(localPath)"),
            """
            main.currentdirectory = groupPath
            let coNamePath = "\(groupPath)/\(items[items.count - 1])"
            if !FileManager.default.fileExists(atPath: coNamePath) {
                // git clone from local mirror
                try runAndPrint("git", "clone", "\(rootPath)/Source/\(groupName)", items[items.count - 1])
                main.currentdirectory = coNamePath
                // 切换对应的分支 或者 tag或者节点
                try runAndPrint("git", "checkout", "-b", checkOutName, checkOutName)
            }
            try changeLocalPackage(rootPath, coNamePath)
        }
        // 如果是主依赖 则添加闭标签]
        replaceContent += """
        
                ]
        """
        // 查找依赖的内容
        guard let range = try packageContent.findPackageDependenciesRange() else {
            return
        }
        var newPackageContent = packageContent as NSString
        newPackageContent = newPackageContent.replacingCharacters(in: range, with: replaceContent) as NSString
        let regxContent = newPackageContent as String
        if let results = try? regxContent.regMatches(#"\/\/[ ]*[\w-:0-9\.]*"#), results.count > 0 {
           let content = "// swift-tools-version:5.1"
           newPackageContent = newPackageContent.replacingCharacters(in: results[0].range, with: content) as NSString
        }
        try newPackageContent.write(toFile: "\(packageDirectory)/Package.swift", atomically: true, encoding: String.Encoding.utf8.rawValue)
        if !isExitMirror {
            try packageContent.write(toFile: "\(packageDirectory)/Package.mirror", atomically: true, encoding: String.Encoding.utf8)
        }
    }

}
