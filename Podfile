# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'XMTest' do
  use_frameworks!

  # Pods for XMTest
  pod 'ReactiveSwift', '~> 6.0'
  pod 'ReactiveCocoa', '~> 10.0'
  pod 'ReactiveFeedback', :git => 'https://github.com/babylonhealth/ReactiveFeedback.git', :branch => 'develop'
  pod 'SnapKit', '~> 5.0'

  target 'XMTestTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'SnapshotTesting', '~> 1.7'
  end

end
