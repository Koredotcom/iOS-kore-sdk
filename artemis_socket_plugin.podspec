Pod::Spec.new do |s|
  s.name             = 'artemis_socket_plugin'
  s.version          = '1.0.0'
  s.summary          = 'Native iOS SDK for Artemis agent WebSocket chat'
  s.description      = <<-DESC
    Artemis Socket Plugin provides a native Swift SDK for connecting to the Artemis
    agent platform via WebSocket, including token management, session handling,
    chat messaging, streaming responses, and history hydration.
  DESC
  s.homepage         = 'https://github.com/kore/artemis_socket_plugin'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Kore.ai' => 'support@kore.ai' }
  s.source           = { :git => 'https://github.com/kore/artemis_socket_plugin.git', :tag => s.version.to_s }

  s.ios.deployment_target = '15.0'
  s.swift_version = '5.9'
  s.module_name = 'ArtemisSocketPlugin'

  s.source_files = 'Sources/ArtemisSocketPlugin/**/*.swift'
  s.frameworks = 'Foundation', 'Combine'

  # CocoaPods trunk currently publishes Yams up to 5.0.6 (SPM has newer releases).
  s.dependency 'Yams', '~> 5.0'
end
