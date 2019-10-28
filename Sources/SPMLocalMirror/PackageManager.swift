//
//  PackageManager.swift
//  SPMLocalMirror
//
//  Created by 张行 on 2019/10/26.
//

import Foundation
import SwiftShell

var localMirrorPath:[String] = []
struct PackageManager {
    func loadContent(_ s:String) throws -> String {
        print("\n\n\(s)")
        let url:URL
        if try s.regMatches(#"http[s]*:"#).count > 0 {
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
        let cachePath = "\(rootPath)/Cache"
        let packagePath = "\(packageDirectory)/Package.swift"
        let packageContent = try loadContent(packagePath)
        try packageContent.write(toFile: "\(packageDirectory)/Package.mirror", atomically: true, encoding: String.Encoding.utf8)
        var newContent = packageContent as NSString
        while true {
            /// 获取当前还存在的依赖
            let manager = DependenciesManager(content: newContent as String)
            let contents:[DependenciesManager.Content] = try manager.contents()
            guard let content = findNetworkContent(contents) else {
                break
            }
            // .package(path: "~/apple/swift-nio-http2")
            let items = content.url.groupItems()
            let groupName = content.url.groupName()
            let groupPath = "\(cachePath)/\(items[items.count - 2])"
            ShellCommand.createDirectory(path: groupPath)
            let itemPath = "\(groupPath)/\(items[items.count - 1])"
            ShellCommand.createDirectory(path: itemPath)
            guard let req = content.requirement else {
                break
            }
            let coName:String
            let clonePath = "\(rootPath)/Source/\(groupName)"
            main.currentdirectory = clonePath
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
                coName = _tempTag
                break
            case .range(let r):
                var _tempTag = ""
                for tag in tags {
                    if tag > _tempTag && tag >= r.major && tag < r.minor {
                        _tempTag = tag
                    }
                }
                coName = _tempTag
                break
            case .closeRanage(let r):
                var _tempTag = ""
                for tag in tags {
                    if tag > _tempTag && tag >= r.major && tag <= r.minor {
                        _tempTag = tag
                    }
                }
                coName = _tempTag
                break
            case .exact(let e):
                coName = e
                break
            case .branch(let b):
                coName = b
                break
            case .revision(let r):
                coName = r
                break
            }
            let localPath = ".package(path: \"\(cachePath)/\(groupName)/\(coName)\")"
            print(localPath)
            localMirrorPath.append(localPath)
            newContent = newContent.replacingCharacters(in: content.range, with: localPath) as NSString
            main.currentdirectory = itemPath
            let coNamePath = "\(itemPath)/\(coName)"
            if !FileManager.default.fileExists(atPath: coNamePath) {
                // git clone from local mirror
                try runAndPrint("git", "clone", "\(rootPath)/Source/\(groupName)", coName)
                main.currentdirectory = coNamePath
                try runAndPrint("git", "checkout", "-b", coName, coName)
            }
            try changeLocalPackage(rootPath, coNamePath)
        }
        try newContent.write(toFile: "\(packageDirectory)/Package.swift", atomically: true, encoding: String.Encoding.utf8.rawValue)
    }
    
    func findNetworkContent(_ contents:[DependenciesManager.Content]) -> DependenciesManager.Content? {
        for content in contents {
            if content.url.contains("http") {
                return content
            }
        }
        return nil;
    }
    
}
