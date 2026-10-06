Pod::Spec.new do |s|
  s.name             = 'artemis_ui_sdk'
  s.version          = '1.0.0'
  s.summary          = 'Native iOS UI SDK for Artemis agent chat'
  s.description      = <<-DESC
    Artemis UI SDK provides a native SwiftUI chat experience with connection
    status, streaming messages, typing feedback, Markdown, and rich content.
    Transport is supplied by artemis_socket_plugin.
  DESC
  s.homepage         = 'https://github.com/kore/artemis_ui_sdk'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Kore.ai' => 'support@kore.ai' }
  s.source           = { :git => 'https://github.com/kore/artemis_ui_sdk.git', :tag => s.version.to_s }

  s.ios.deployment_target = '15.0'
  s.swift_version = '5.9'
  s.module_name = 'ArtemisUISDK'
  s.source_files = 'Sources/ArtemisUISDK/**/*.swift'
  s.frameworks = 'Foundation', 'SwiftUI', 'Combine', 'UIKit'
  s.dependency 'artemis_socket_plugin', '~> 1.0'
end
