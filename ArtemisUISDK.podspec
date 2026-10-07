Pod::Spec.new do |s|
  s.name             = 'ArtemisUISDK'
  s.version          = '1.0.1'
  s.summary          = 'Native iOS UI SDK for Artemis agent chat'
  s.description      = <<-DESC
    Artemis UI SDK provides a native SwiftUI chat experience with connection
    status, streaming messages, typing feedback, Markdown, and rich content.
    Transport is supplied by ArtemisSocketSDK.
  DESC
  s.homepage         = 'https://github.com/Koredotcom/artemis-ios-sdk'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Pagidimarri Kartheek' => 'Kartheek.Pagidimarri@kore.com' }
  s.source           = { :git => 'https://github.com/Koredotcom/artemis-ios-sdk.git', :tag => s.version.to_s }

  s.ios.deployment_target = '15.0'
  s.swift_version = '5.9'
  s.module_name = 'ArtemisUISDK'
  s.source_files = 'Sources/ArtemisUISDK/**/*.swift'
  s.frameworks = 'Foundation', 'SwiftUI', 'Combine', 'UIKit'
  s.dependency 'ArtemisSocketSDK', '1.0.0'
end
