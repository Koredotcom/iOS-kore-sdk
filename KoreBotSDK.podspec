Pod::Spec.new do |s|
    s.name = 'KoreBotSDK'
    s.version = '0.1.2'
    s.license  = {:type => 'MIT', :file => 'KoreBotSDK/LICENSE' }
    s.summary = 'KoreBotSDK lets a user interact with Kore bots'
    s.homepage = 'https://kore.ai'
    s.author = {'Srinivas Vasadi' => 'srinivas.vasadi@kore.com'}
    s.source = {:git => 'https://github.com/Koredotcom/iOS-kore-sdk.git', :tag => s.version, :submodules => true }
    s.requires_arc = true

    s.public_header_files = 'KoreBotSDK/KoreBotSDK.h'
    s.source_files = 'KoreBotSDK/KoreBotSDK.h'

    s.swift_version = '4.2'

    s.subspec 'Library' do |ss|
        ss.ios.deployment_target = '12.0'
        ss.source_files = 'KoreBotSDK/**/*.{h,m,swift}'
        
        ss.dependency 'Starscream'
        ss.dependency 'ObjectMapper'
        ss.dependency 'AlamofireImage'
        ss.dependency 'Alamofire'
        ss.ios.frameworks = 'SystemConfiguration'
    end

    s.subspec 'UIKit' do |ss|
        ss.ios.deployment_target = '12.0'
        ss.source_files = 'Widgets/**/*.{h,m,txt,swift,xib}'
        ss.resource_bundles = {
            'Templates' => ['Widgets/**/*.xib'],
            'Widgets' => ['Widgets/Widgets/**/**/*.xib'],
            'Lato' => ['Widgets/Resources/Fonts/Lato/*.ttf'],
            'BebasNeue' => ['Widgets/Resources/Fonts/BebasNeue/*.ttf'],
            'Symbols' => ['Widgets/Resources/Fonts/AppSymbols/*.ttf'],
        }
        ss.resources = ['Widgets/Widgets/**/*.{xcdatamodeld}', 'Widgets/Resources/*.{xcassets}']
        ss.dependency 'AlamofireImage'
        ss.dependency 'GhostTypewriter'
        ss.dependency 'MarkdownKit'
        #ss.dependency 'Charts', '~> 3.2.2'
        ss.dependency 'DGCharts'
        ss.dependency 'ObjectMapper'
	ss.dependency 'AssetsPickerViewController'
	ss.dependency 'SwiftUTI'
	ss.dependency 'emojione-ios'
        ss.ios.frameworks = 'SystemConfiguration'
    end
end
