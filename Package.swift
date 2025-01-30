// swift-tools-version: 5.4

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
		.package(url: "https://github.com/dagronf/DSFAppearanceManager", from: "3.5.1"),
	],
	targets: [
		.target(
			name: "DSFStepperView", 
			dependencies: ["DSFAppearanceManager"],
			resources: [
				.copy("PrivacyInfo.xcprivacy"),
			]
		),
		.testTarget(name: "DSFStepperViewTests", dependencies: ["DSFStepperView"]),
	]
)
