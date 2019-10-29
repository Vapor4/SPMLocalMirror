# SPMLocalMirror

## 本地镜像加速器

> 原理是下载网络依赖到本地 使用本地依赖加速

## 使用

```shell
cd Example
SPMLocalMirror local
```

> 相当于 `SPMLocalMirror local --path $PWD --type build`

#### --path

> 指定本地`Package.swift`所在的目录 不指定 默认为当前终端的路径

#### --type

> 指定类型
>
> - build
>
>   > 相当于执行了 `swift build`
>
> - xcode
>
>   > 相当于执行了 `swift package generate-xcodeproj`

