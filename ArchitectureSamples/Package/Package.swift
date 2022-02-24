// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Package",
    defaultLocalization: "en",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(
            name: "ProjectBase",
            targets: ["Loging", "PresentationCommon", "Model", "Constant", "AppError"]
        ),
        .library(
            name: "Usecase",
            targets: ["AppContainer", "Usecase"]
        ),
        .library(
            name: "Repository",
            targets: ["AppRepositoryContainer", "Repository"]
        ),
        .library(
            name: "RxDependencies",
            targets: ["RxDependencies"]
        )
    ],
    dependencies: [
        .package(name: "Moya", url: "https://github.com/Moya/Moya.git", from: "15.0.0"),
        .package(name: "Nuke", url: "https://github.com/kean/Nuke.git", from: "10.7.1"),
        .package(name: "SwiftyBeaver", url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", from: "1.9.5"),
        .package(name: "SwiftEntryKit", url: "https://github.com/huri000/SwiftEntryKit.git", from: "2.0.0"),
        .package(name: "RxSwift", url: "https://github.com/ReactiveX/RxSwift.git", .exact("6.5.0"))
    ],
    targets: [
        .target(name: "AppError"),
        .target(name: "Constant"),
        .target(
            name: "AppContainer",
            dependencies: [
                "Usecase"
            ]
        ),
        .target(
            name: "AppRepositoryContainer",
            dependencies: [
                "Repository"
            ]
        ),
        .target(
            name: "Loging",
            dependencies: [
                "SwiftyBeaver"
            ]
        ),
        .target(
            name: "PresentationCommon",
            dependencies: [
                "Nuke",
                "SwiftEntryKit"
            ]
        ),
        .target(name: "Model"),
        .target(
            name: "Repository",
            dependencies: [
                "Model",
                "Network"
            ]
        ),
        .target(
            name: "Usecase",
            dependencies: [
                "Model",
                "Repository"
            ]
        ),
        .target(
            name: "Network",
            dependencies: [
                "AppError",
                "Loging",
                "Model",
                "Constant",
                .product(name: "Moya", package: "Moya", condition: .when(platforms: [.iOS]))
            ]
        ),
        .target(
            name: "RxDependencies",
            dependencies: [
                .product(name: "RxMoya", package: "Moya", condition: .when(platforms: [.iOS])),
                .product(name: "RxSwift", package: "RxSwift", condition: .when(platforms: [.iOS])),
                .product(name: "RxCocoa", package: "RxSwift", condition: .when(platforms: [.iOS])),
                .product(name: "RxRelay", package: "RxSwift", condition: .when(platforms: [.iOS]))
            ]
        )
    ]
)
