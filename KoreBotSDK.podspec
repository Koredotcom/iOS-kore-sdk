Pod::Spec.new do |s|
    s.name = 'KoreBotSDK'
    s.version = '1.0.7'
    s.license  = {:type => 'MIT', :file => 'LICENSE' }
    s.summary = 'KoreBotSDK lets a user interact with Kore bots'
    s.homepage = 'https://kore.ai'
    s.author = {'Srinivas Vasadi' => 'srinivas.vasadi@kore.com'}
    s.source = {:git => 'https://github.com/Koredotcom/iOS-kore-sdk.git', :tag => s.version, :submodules => true }
    s.requires_arc = true

    s.public_header_files = 'KoreBotSDK/KoreBotSDK.h'
    s.source_files = 'KoreBotSDK/KoreBotSDK.h'

    s.swift_version = '4.2'
    s.ios.deployment_target = '12.0'
    s.source_files = 'Sources/**/*.{h,m,swift}'
    s.resources = ['Sources/**/*.{xcdatamodeld}', 'Sources/**/*.{xcassets}','Sources/**/*.xib','Sources/Widgets/**/**/*.xib','Sources/**/*.json','Sources/**/*.lproj']
    s.dependency 'Alamofire'
    s.dependency 'AlamofireImage'
    s.dependency 'Starscream'
    s.dependency 'ObjectMapper'
    s.dependency 'GhostTypewriter'
    #s.dependency 'MarkdownKit'
    s.dependency 'DGCharts'
    s.dependency 'ObjectMapper'
    s.dependency 'FMPhotoPicker'
    s.dependency 'SwiftUTI'
    s.dependency 'Emoji-swift'
    s.ios.frameworks = 'SystemConfiguration'
end
