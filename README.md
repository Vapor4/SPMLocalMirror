# SPMLocalMirror

## 本地镜像加速器(Local mirror accelerator)

> 原理是下载网络依赖到本地 使用本地依赖加速(The principle is to download network dependencies to local use local dependency acceleration)

## Install
```
brew install vapor4/homebrew-taps/spmlocalmirror
```

## 使用(How to use)

```shell
cd Example
SPMLocalMirror local
```

> 相当于 `SPMLocalMirror local --path $PWD --type build`(equal `SPMLocalMirror local --path $PWD --type build`)

#### --path

> 指定本地`Package.swift`所在的目录 不指定 默认为当前终端的路径(Specify the directory where the local `Package.swift` is located. Do not specify the path to the current terminal by default.)

#### --type

> 指定类型(Specified type)
>
> - build
>
>   > 相当于执行了 `swift build`(Equivalent to executing `swift build`)
>
> - xcode
>
>   > 相当于执行了 `swift package generate-xcodeproj`(Equivalent to executing `swift package generate-xcodeproj`)

