//
//  PackageManager.swift
//  SPMLocalMirror
//
//  Created by 张行 on 2019/10/26.
//

import Foundation

//            guard let _ = URL(string: resutString) else {
//                throw MirrorError.systemError
//            }
//            if !packages.contains(resutString) {
//                packages.append(resutString)
//            }
//
//            let list = resutString.components(separatedBy: "/")
//            let count = list.count
//            let groupName = "\(list[count - 2])/\(list[count - 1])"
//            let packagePath = "https://raw.githubusercontent.com/\(groupName)/master/Package.swift"
//            let result = try loadPackageSwift(packagePath)
//            try parsePackageContent(result, &packages)

struct PackageManager {
    func loadContent(_ s:String) throws -> String? {
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
    func parsePackageContent(_ content:String) throws -> [String] {
        var contentPackages:[String] = []
        let regx = #".package\(url:[ "\w:\/.-]*"#
        let reg = try? NSRegularExpression(pattern: regx, options: [])
        guard let results:[NSTextCheckingResult] = reg?.matches(in: content, options: [], range: NSRange(content.startIndex..., in: content)) else {
            throw MirrorError.systemError
        }
        for result in results {
            let contentString:NSString = content as NSString
            let resutString = contentString.substring(with: result.range)
            contentPackages.append(try parseRegURL(resutString))
        }
        return contentPackages
    }
    
    func parseRegURL(_ url:String) throws -> String {
        let regx = #"http[\w:\/]*.[\w\/-]*"#
        let reg = try? NSRegularExpression(pattern: regx, options: [])
        guard let results:[NSTextCheckingResult] = reg?.matches(in: url, options: [], range: NSRange(url.startIndex..., in: url)) else {
            throw MirrorError.systemError
        }
        guard let first = results.first else {
            throw MirrorError.systemError
        }
        let contentString:NSString = url as NSString
        let resutString = contentString.substring(with: first.range)
        return resutString
    }
    
    func append
}
