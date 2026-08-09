// swift-tools-version: 6.0
@preconcurrency import PackageDescription

#if TUIST
    @preconcurrency import ProjectDescription
    import ProjectDescriptionHelpers

    let packageSettings = PackageSettings(
        // 기본값은 .staticFramework 입니다.
        // 동적 프레임워크가 필요한 패키지만 여기에 .framework 로 지정하세요.
        // 일부만 동적으로 바꾸면 정적 의존성과 섞이면서 링크 에러가 날 수 있으니,
        // 바꿀 때는 해당 패키지의 의존성 트리를 함께 옮겨야 합니다.
        productTypes: [:],
        baseSettings: .externalPackageSettings()
    )
#endif

let package = Package(
    name: "Anywhere",
    dependencies: [
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            from: "12.17.0"
        ),
        .package(
            url: "https://github.com/google/GoogleSignIn-iOS",
            from: "9.2.0"
        ),
    ]
)
