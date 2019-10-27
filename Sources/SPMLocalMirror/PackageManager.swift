//
//  PackageManager.swift
//  SPMLocalMirror
//
//  Created by 张行 on 2019/10/26.
//

import Foundation



struct PackageManager {
    func loadContent(_ s:String) throws -> String {
        let url:URL
        if s.contains("http") {
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
                var url = content.url
                print(url)
                if let range = url.range(of: ".git") {
                    url = String(url[url.startIndex..<range.lowerBound])
                }
                let subPaths = url.components(separatedBy: "/")
                let name = "\(subPaths[subPaths.count - 2])/\(subPaths[subPaths.count - 1])"
                let subPackageURL = "https://raw.githubusercontent.com/\(name)/master/Package.swift"
                print(subPackageURL)
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
}
