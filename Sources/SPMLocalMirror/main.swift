import Commander
import SwiftShell
import Foundation



Group { (g) in
    g.command(
        "init",
        Argument<String>("url", description: "Package.swift的本地地址或者网络地址")
    ) { path in
        let packageManager = PackageManager()
        let content = try packageManager.loadContent(path)
        try packageManager.appenURLInDependencies(content)
        print(dependencies)
    }
    g.command(
        "local",
        Argument<String>("package", description: "请输入本地Package.swift的绝对路径地址")
    ) { package in
        
    }
}.run()



