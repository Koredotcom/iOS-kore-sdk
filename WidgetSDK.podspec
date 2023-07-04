Pod::Spec.new do |s|
    s.name = 'WidgetSDK'
    s.version = '0.1.2'
    s.license  = {:type => 'MIT', :file => 'WidgetSDK/LICENSE' }
    s.summary = 'WidgetSDK lets a user interact with Kore bots'
    s.homepage = 'https://kore.ai'
    s.author = {'Srinivas Vasadi' => 'srinivas.vasadi@kore.com'}
    s.source = {:git => 'https://github.com/Koredotcom/iOS-kore-sdk.git', :tag => s.version, :submodules => true }
    s.requires_arc = true

    s.public_header_files = 'WidgetSDK/WidgetSDK.h'
    s.source_files = 'WidgetSDK/WidgetSDK.h'

    s.swift_version = '4.2'

    s.subspec 'Library' do |ss|
        ss.ios.deployment_target = '11.0'
        ss.source_files = 'WidgetSDK/**/*.{h,m,swift}'
        
        ss.dependency 'Mantle', '2.1.0'
        ss.dependency 'AFNetworking', '4.0.1'
        ss.dependency 'SocketRocket'
        
        ss.ios.frameworks = 'SystemConfiguration'
    end

 s.subspec 'UIKit' do |ss|
        ss.ios.deployment_target = '11.0'
        ss.source_files = ['Widgets/**/*.{h,m,txt,swift,xib}']
        ss.resource_bundles = {
            'Templates' => ['Widgets/**/*.xib'],
            'Widgets' => ['Widgets/Widgets/**/**/*.xib'],
            'Lato' => ['Widgets/Resources/Fonts/Lato/*.ttf'],
            'BebasNeue' => ['Widgets/Resources/Fonts/BebasNeue/*.ttf'],
            'Symbols' => ['Widgets/Resources/Fonts/AppSymbols/*.ttf'],
        }
        ss.resources = ['KoreAssitant/**/*.{xcassets}','Widgets/Widgets/**/*.{xcdatamodeld}', 'Widgets/Resources/*.{xcassets}']
        ss.dependency 'AFNetworking', '4.0.1'
        ss.dependency 'GhostTypewriter'
        ss.dependency 'MarkdownKit'
        ss.dependency 'Charts', '~> 3.2.2'
    end
   
end
