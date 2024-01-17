// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "DSFStepperView",
	platforms: [
		.macOS(.v10_13),
		.iOS(.v13),
		.tvOS(.v13)
	],
	products: [
		.library(name: "DSFStepperView", targets: ["DSFStepperView"]),
		.library(name: "DSFStepperView-static", type: .static, targets: ["DSFStepperView"]),
		.library(name: "DSFStepperView-shared", type: .dynamic, targets: ["DSFStepperView"]),
	],
	dependencies: [
		.package(url: "https://github.com/dagronf/DSFAppearanceManager", from: "3.4.0"),
	],
	targets: [
		.target(name: "DSFStepperView", dependencies: ["DSFAppearanceManager"]),
		.testTarget(name: "DSFStepperViewTests", dependencies: ["DSFStepperView"]),
	]
)
