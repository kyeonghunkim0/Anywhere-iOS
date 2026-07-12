// swift-tools-version: 6.0
import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        // productTypes: ["Alamofire": .framework,]
        productTypes: [:]
    )
#endif

let package = Package(
    name: "Anywhere",
    dependencies: [
              .package(url: "https://github.com/airbnb/lottie-ios", from: "4.5.0"),
              .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.6.4"),
              .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.10.0")
          ]
)
