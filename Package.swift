// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "DSFStepperView",
	platforms: [
		.macOS(.v10_11),
		.iOS(.v13),
		.tvOS(.v13)
	],
	products: [
		.library(name: "DSFStepperView", type: .static, targets: ["DSFStepperView"]),
		.library(name: "DSFStepperView-shared", type: .dynamic, targets: ["DSFStepperView"]),
	],
	targets: [
		.target(name: "DSFStepperView", dependencies: []),
		.testTarget(name: "DSFStepperViewTests", dependencies: ["DSFStepperView"]),
	]
)
