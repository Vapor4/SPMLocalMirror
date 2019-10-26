import Commander
import SwiftShell
import Foundation



Group { (g) in
    g.command(
        "init",
        Argument<String>("url", description: "Package.swift的本地地址或者网络地址")
    ) { path in
        
    }
}.run()

//let installCommand = command(
//    Argument<String>("init", description: "根据提供的Package.swift进行分析依赖本地"),
//    Argument<String>("path", description: "设置根目录")
//) { package, path in
//    rootPath = path
//    do {
//        let result = try loadPackageSwift(package)
//        try parsePackageContent(result, &dependencies)
//        for url in dependencies {
//            let path = "\(rootPath)/SPMLocalMirror"
//            var isDirectory = ObjCBool(false)
//            if !FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) {
//                print(run("mkdir", path).stderror)
//            }
//            let list = url.components(separatedBy: "/")
//            let groupPath = "\(path)/\(list[list.count - 2])"
//            if !FileManager.default.fileExists(atPath: groupPath, isDirectory: &isDirectory) {
//                print(run("mkdir", groupPath).stderror)
//            }
//            let detailPath = "\(groupPath)/\(list[list.count - 1])"
//            if !FileManager.default.fileExists(atPath: detailPath, isDirectory: &isDirectory) {
//                print(run("git","clone",url, detailPath).stderror)
//            } else {
//                print(run("git","-C" , detailPath ,"reset","--hard").stderror)
//                print(run("git","-C" , detailPath ,"pull").stderror)
//            }
//            let packagePath = "\(detailPath)/Package.swift"
//            
//        }
//    } catch {
//        print(error.localizedDescription)
//    }
//}
//installCommand.run()


