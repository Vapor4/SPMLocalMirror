//
//  DependenciesManager.swift
//  SPMLocalMirror
//
//  Created by 张行 on 2019/10/27.
//

import Foundation
struct DependenciesManager {
    let content:String
    
    // .package(url: "https://github.com/apple/swift-nio-http2.git", from: "1.0.0")
    func versions() throws -> [Content] {
        return try subContents(#"\.package\([\w: "\/.\-,]*from:[ "\w0-9.-]*\)"#) { result in
            guard let results = try? result.0.regMatches(#""[\w~:\/\-.]*""#) else {
                return nil
            }
            return DependenciesManager.Content(
                url: results[0].content.removeDoubleQuotes(),
                requirement: DependenciesManager.Content.Requirement.from(results[1].content.removeDoubleQuotes()),
                range: result.1
            )
        }
    }
    
    // .package(path: "~/apple/swift-nio-http2")
    func paths() throws -> [Content] {
        return try subContents(#"\.package\(path:[ \w"\/-]*\)"#) { result in
            guard let results = try? result.0.regMatches(#""[\w~:\/\-.]*""#) else {
                return nil
            }
            return DependenciesManager.Content(
                url: results[0].content.removeDoubleQuotes(),
                requirement: nil,
                range: result.1
            )
        }
    }
    // .package(url: "https://github.com/apple/swift-nio-http2.git", "1.0.0"..<"1.6.1")
    func ranges() throws -> [Content] {
        return try subContents(#"\.package\(url:[\w ":\/\.\-,]*\.\.<"[0-9\.]*"\)"#) { result in
            guard let results = try? result.0.regMatches(#""[\w~:\/\-.]*""#) else {
                return nil
            }
            return DependenciesManager.Content(
                url: results[0].content.removeDoubleQuotes(),
                requirement: DependenciesManager.Content.Requirement.range(DependenciesManager.Range(major: results[1].content.removeDoubleQuotes(), minor: results[2].content.removeDoubleQuotes())),
                range: result.1
            )
        }
    }
    
    // .package(url: "https://github.com/apple/swift-nio-http2.git", "1.0.0"..."1.6.1")
    func closeRange() throws -> [Content] {
        return try subContents(#"\.package\(url:[\w ":\/\.\-,]*\.\.\."[0-9\.]*"\)"#) { result in
            guard let results = try? result.0.regMatches(#""[\w~:\/\-.]*""#) else {
                return nil
            }
            return DependenciesManager.Content(
                url: results[0].content.removeDoubleQuotes(),
                requirement: DependenciesManager.Content.Requirement.range(DependenciesManager.Range(major: results[1].content.removeDoubleQuotes(), minor: results[2].content.removeDoubleQuotes())),
                range: result.1
            )
        }
    }
    
    // .package(url: "https://github.com/apple/swift-nio-http2.git", .exact("1.0.0"))
    func exacts() throws -> [Content] {
        return try subContents(#"\.package\(url:[ ]*"[\w:\/.-]*",[ ]*.exact\("[0-9.]*"\)\)"#) { result in
            guard let results = try? result.0.regMatches(#""[\w~:\/\-.]*""#) else {
                return nil
            }
            return DependenciesManager.Content(
                url: results[0].content.removeDoubleQuotes(),
                requirement: DependenciesManager.Content.Requirement.exact(results[1].content.removeDoubleQuotes()),
                range: result.1
            )
        }
    }
    // .package(url: "https://github.com/apple/swift-nio-http2.git", .branch("master"))
    func branchs() throws -> [Content] {
        return try subContents(#"\.package\(url:[ ]*"[\w:\/.-]*",[ ]*.branch\("[\w]*"\)\)"#) { result in
            guard let results = try? result.0.regMatches(#""[\w~:\/\-.]*""#) else {
                return nil
            }
            return DependenciesManager.Content(
                url: results[0].content.removeDoubleQuotes(),
                requirement: DependenciesManager.Content.Requirement.branch(results[1].content.removeDoubleQuotes()),
                range: result.1
            )
        }
    }
    // .package(url: "https://github.com/apple/swift-nio-http2.git", .revision("a92923b"))
    func revision() throws -> [Content] {
        return try subContents(#"\.package\(url:[ ]*"[\w:\/.-]*",[ ]*.revision\("[\w]*"\)\)"#) { result in
            guard let results = try? result.0.regMatches(#""[\w~:\/\-.]*""#) else {
                return nil
            }
            return DependenciesManager.Content(
                url: results[0].content.removeDoubleQuotes(),
                requirement: DependenciesManager.Content.Requirement.revision(results[1].content.removeDoubleQuotes()),
                range: result.1
            )
        }
    }
        
    func contents() throws -> [Content] {
        var contents:[Content] = []
        contents.append(contentsOf: try versions())
        contents.append(contentsOf: try ranges())
        contents.append(contentsOf: try closeRange())
        contents.append(contentsOf: try paths())
        contents.append(contentsOf: try exacts())
        contents.append(contentsOf: try branchs())
        contents.append(contentsOf: try revision())
        return contents
    }
    
    func subContents(_ packageRegx:String, _ contentBlock:((String,NSRange)) -> Content?) throws -> [Content] {
        var contents:[Content] = []
        let results = try content.regMatches(packageRegx)
        for result in results {
            print(result.content)
            if let content = contentBlock(result) {
                contents.append(content)
            }
        }
        return contents
    }
}

extension DependenciesManager {
    struct Content {
        enum Requirement {
            case from(_ s:String)
            case range(_ r:Range)
            case closeRanage(_ cr:Range)
            case exact(_ e:String)
            case branch(_ b:String)
            case revision(_ r:String)
        }
        let url:String
        let requirement:Requirement?
        let range:NSRange
    }
}

extension DependenciesManager {
    struct Range  {
        public let major: String
        public let minor: String
    }
    
}
