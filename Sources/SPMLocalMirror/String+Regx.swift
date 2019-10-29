//
//  String+Regx.swift
//  SPMLocalMirror
//
//  Created by 张行 on 2019/10/26.
//

import Foundation
/**
 .package\(url:[ ]*"[\w:\/.-]*",[ ]*from:[ ]*"[\w.]*"\)
 .package(url: "https://github.com/apple/swift-nio-http2.git", from: "1.0.0")
 */
extension String {
    func regMatches(_ pattern:String) throws -> [(content:String, range:NSRange)] {
        var matcheResults:[(String,NSRange)] = []
        let regularExpression = try? NSRegularExpression(pattern: pattern, options: [])
        guard let results:[NSTextCheckingResult] = regularExpression?.matches(in: self, options: [], range: NSRange(self.startIndex..., in: self)) else {
            throw MirrorError.systemError
        }
        for result in results {
            let contentString:NSString = self as NSString
            let resutString = contentString.substring(with: result.range)
            matcheResults.append((resutString, result.range))
        }
        return matcheResults
    }
}

extension String {
    func removeDoubleQuotes() -> String {
        guard let results = try? self.regMatches(#"[\w:\/.-]*"#) else {
            return self
        }
        return results[1].content
    }
    func groupName() -> String {
        let subPaths = self.groupItems()
        let name = "\(subPaths[subPaths.count - 2])/\(subPaths[subPaths.count - 1])"
        return name
    }
    func groupItems() -> [String] {
        var url = self
        if let range = url.range(of: ".git") {
            url = String(url[url.startIndex..<range.lowerBound])
        }
        let subPaths = url.components(separatedBy: "/")
        return subPaths
    }
}

extension String {
    func findPackageDependenciesRange() throws -> NSRange? {
        let results = try self.regMatches(#"[ ]*\[[^\]]*\]"#)
        for result in results {
            if result.content.contains(".package") {
                return result.range
            }
        }
        return nil
    }
}

extension String {
    /// 是否是网络源依赖
    func isURLDependencies() throws -> Bool {
        return try self.regMatches(#"http[s]*:"#).count > 0
    }
}
