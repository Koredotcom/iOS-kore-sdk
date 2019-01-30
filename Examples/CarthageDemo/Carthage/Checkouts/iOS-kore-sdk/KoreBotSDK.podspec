Pod::Spec.new do |s|
    s.name = 'KoreBotSDK'
    s.version = '0.1.1'
    s.license  = {:type => 'MIT', :file => 'KoreBotSDK/LICENSE' }
    s.summary = 'KoreBotSDK lets a user interact with Kore bots'
    s.homepage = 'https://kore.ai'
    s.author = {'Srinivas Vasadi' => 'srinivas.vasadi@kore.com'}
    s.source = {:git => 'https://github.com/Koredotcom/iOS-kore-sdk.git', :tag => s.version, :submodules => true }
    s.requires_arc = true

    s.public_header_files = 'KoreBotSDK/KoreBotSDK.h'
    s.source_files = 'KoreBotSDK/KoreBotSDK.h'

    s.ios.deployment_target = '8.0'
    s.swift_version = '4.2'

    s.subspec 'Library' do |ss|
        ss.ios.deployment_target = '8.0'
        ss.source_files = 'KoreBotSDK/**/*.{h,m,swift}'
        
        ss.dependency 'Mantle', '2.0.2'
        ss.dependency 'AFNetworking', '3.2.0'
        ss.dependency 'SocketRocket'
        
        ss.ios.frameworks = 'SystemConfiguration'
    end

    s.subspec 'UIKit' do |ss|
        ss.ios.deployment_target = '8.0'
        ss.source_files = 'Widgets/**/*.{h,m,txt,swift,xib}'
        ss.resource_bundles = {
            'Widgets' => ['Widgets/**/*.xib']
        }

        ss.dependency 'AFNetworking', '3.2.0'
        ss.ios.frameworks = 'SystemConfiguration'
    end
end
