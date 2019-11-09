//
//  DependenciesManager.swift
//  SPMLocalMirror
//
//  Created by 张行 on 2019/10/27.
//

import Foundation
import SwiftShell
struct DependenciesManager {
    let content:String
    func contents(_ cache:String) throws -> [Content] {
        let packagePath = "\(cache)/Package.swift"
        try self.content.write(toFile: packagePath, atomically: true, encoding: String.Encoding.utf8)
        main.currentdirectory = cache
        let json = run("swift", "package", "dump-package").stdout
        guard let data = json.data(using: String.Encoding.utf8) else {
            print("获取Package.swift解析失败")
            throw MirrorError.systemError
        }
        let spmJSON:SPMJSON = try JSONDecoder().decode(SPMJSON.self, from: data)
        return spmJSON.dependencies
    }
}

extension DependenciesManager {
    struct Content : Codable {
        struct Requirement : Codable {
            struct Range : Codable {
                var lowerBound:String
                var upperBound:String
            }
            var localPackage:String?
            var range:[Range]?
            var branch:[String]?
            var exact:[String]?
            var revision:[String]?
        }
        let url:String
        let requirement:Requirement?
    }
    struct SPMJSON : Codable {
        var dependencies : [Content]
    }
}

