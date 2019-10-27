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
    func regMatches(_ pattern:String) throws -> [String] {
        var matcheResults:[String] = []
        let regularExpression = try? NSRegularExpression(pattern: pattern, options: [])
        guard let results:[NSTextCheckingResult] = regularExpression?.matches(in: self, options: [], range: NSRange(self.startIndex..., in: self)) else {
            throw MirrorError.systemError
        }
        for result in results {
            let contentString:NSString = self as NSString
            let resutString = contentString.substring(with: result.range)
            matcheResults.append(resutString)
        }
        return matcheResults
    }
}

extension String {
    func removeDoubleQuotes() -> String {
        guard let results = try? self.regMatches(#"[\w:\/.-]*"#) else {
            return self
        }
        return results[1]
    }
}
