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
        print("\n\n\(s)")
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
    
    func appenURLInDependencies(_ content:String) throws {
        let dependenciesManager = DependenciesManager(content: content)
        let contents = try dependenciesManager.contents()
        for content in contents {
            if !isExitDependencies(content) {
                dependencies.append(content)
            }
            if let _ = content.requirement {
                let name = content.url.groupName()
                let subPackageURL = "https://raw.githubusercontent.com/\(name)/master/Package.swift"
                let subContent = try loadContent(subPackageURL)
                try appenURLInDependencies(subContent)
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
        let contents:[DependenciesManager.Content] = try manager.contents()
        for content in contents {
            // 是否是网络依赖
            let isURLDependencies = try self.isURLDependencies(content.url)
            if  !isURLDependencies {
                // 如果是本地的依赖
                replaceContent += """
                
                        .package(path: "\(content.url)"),
                """
            } else {
                let items = content.url.groupItems()
                let groupName = content.url.groupName()
                let groupPath = "\(cachePath)/\(items[items.count - 2])"
                ShellCommand.createDirectory(path: groupPath)
                // 如果是我们不支持的类型 则放弃
                guard let req = content.requirement else {
                    break
                }
                // Checkout 下来的名称
                let checkOutName:String
                // Clone源的路径地址
                let clonePath = "\(rootPath)/Source/\(groupName)"
                main.currentdirectory = clonePath
                // 获取所有的源支持的Tag
                let tagOutput = run("git", "tag")
                let tags = tagOutput.stdout.components(separatedBy: "\n")
                switch req {
                case .from(let f):
                    var _tempTag = ""
                    for tag in tags {
                        if tag > _tempTag && tag >= f {
                            _tempTag = tag
                        }
                    }
                    checkOutName = _tempTag
                    break
                case .range(let r):
                    var _tempTag = ""
                    for tag in tags {
                        if tag > _tempTag && tag >= r.major && tag < r.minor {
                            _tempTag = tag
                        }
                    }
                    checkOutName = _tempTag
                    break
                case .closeRanage(let r):
                    var _tempTag = ""
                    for tag in tags {
                        if tag > _tempTag && tag >= r.major && tag <= r.minor {
                            _tempTag = tag
                        }
                    }
                    checkOutName = _tempTag
                    break
                case .exact(let e):
                    checkOutName = e
                    break
                case .branch(let b):
                    checkOutName = b
                    break
                case .revision(let r):
                    checkOutName = r
                    break
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
        try newPackageContent.write(toFile: "\(packageDirectory)/Package.swift", atomically: true, encoding: String.Encoding.utf8.rawValue)
        if !isExitMirror {
            try packageContent.write(toFile: "\(packageDirectory)/Package.mirror", atomically: true, encoding: String.Encoding.utf8)
        }
    }

}
