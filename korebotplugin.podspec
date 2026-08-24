Pod::Spec.new do |s|
  s.name = 'korebotplugin'
  s.version = '11.0.2'
  s.summary = 'Vendored Kore.ai native iOS Bot SDK for the OutSystems Cordova wrapper.'
  s.homepage = 'https://kore.ai'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'Kore.ai' => 'support@kore.ai' }
  s.source = {
    :git => 'https://github.com/Koredotcom/iOS-kore-sdk.git',
    :branch => 'outSystems'
  }
  s.platform = :ios, '13.0'
  s.swift_version = '5.0'

  s.source_files = [
    'KoreBotSDK/**/*.{h,m,swift}',
    'ObjcSupport/**/*.{h,m}'
  ]
  s.resource_bundles = {
    'KoreBotSDK' => [
      'KoreBotSDK/**/*.{xcassets,xcdatamodeld,xib,json,lproj,ttf}'
    ]
  }
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }

  s.dependency 'Alamofire'
  s.dependency 'AlamofireImage'
  s.dependency 'Starscream'
  s.dependency 'ObjectMapper'
  s.dependency 'GhostTypewriter'
  s.dependency 'DGCharts'
  s.dependency 'FMPhotoPicker'
  s.dependency 'SwiftUTI'
  s.dependency 'Emoji-swift'
end
