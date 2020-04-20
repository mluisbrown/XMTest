# Demo project for XM Mobile team

## Installation

The project uses Cocoapods for library dependencies, but in order to make this test project plug and play I opted to commit the Pods to the git repo, so you should just be able to open the [XMTest.xcworkspace](./XMTest.xcworkspace) and immediately Build, Run and Test.

I created the project with Xcode 11.4 and Swift 5.2.

## Architecture

I opted to use a style of MVVM-C using [Reactive Swift](https://github.com/ReactiveCocoa/ReactiveSwift) and a [Reactive Feedback](https://github.com/babylonhealth/ReactiveFeedback). I'm using the `develop` branch of Reactive Feedback which now has support for using a single store with composable `Feedback`s and reducers, which makes this architecture very similar to the PointFree composable architecture.

I'm also using just UIKit for the UI, with SnapKit for helping with Auto Layout.

### Rationale for architecture choices

I was tempted to use the PointFree composable architecture as it currently exists, together with Combine and SwiftUI. However, given a test with a time limit, I opted to stick with what I am most familiar with to avoid spending too much time solving issues that would come up with using APIs I'm less familiar with.

By using the composable, single store, version of Reactive Feedback, I have managed a compromise between using an architecture similar to the Pointfree one, but at the same time still familiar to me.

I also wanted to use a declarative UI framework. However, I don't have enough experience with SwiftUI yet to want to do a test project with it, and the version of [Bento](https://github.com/babylonhealth/Bento) that is open source is far behind the version I have been using at Babylon Health. 

Learning a different declarative framework, like [Carbon](https://github.com/ra1028/Carbon) would mean using something that is even more unfamiliar to me than SwiftUI.

## Testability

Again influenced by Pointfree, I opted to use their `Environment` global dependency container approach. In this simple project, the only real dependency is the network API. Using this approach, I was able to create a mock [Network](./XMTest/Networking/Network.swift) instance which provides canned responses for API requests. By using differnet static instances of `World` it can quickly be configured to fail for question submission, or not:

```swift
// for the real network layer
var Current: World = .production

// for mock network
var Current: World = .mock

// for failing mock network
var Current: World = .failingMock
```

I'm using the mock network in the view model tests so that the feedbacks that make network calls can also be properly tested. The mock network could also be used for UI tests.

### Snapshot testing

I'm using Pointfree's Swift Snapshot Testing library for snapshot testing both of the views. With this architecture, since all the view controlller's need to be instantiated is a `Store` instance, it is trivial to snapshot test them for all the differnent states of the `Store`.

FYI: I ran the snapshot tests on the "iPhone 11 Pro" simulator. Unfortunately the snapshot library is not simulator agnostic, so if you use a different simulator there may well be mismatches.

### Test source files

The test sources are in `Test` subfolders together with the code they are testing. I find this makes it much easier to find test sources than having them all in a separate top level folder structure just for tests.