Pod::Spec.new do |s|
    s.name = "KoreBotSDK"
    s.version = "0.0.9"
    s.license  = {:type => "MIT", :file => "KoreBotSDK/LICENSE" }
    s.summary = "KoreBotSDK lets a user interact with Kore bots"
    s.homepage = "https://kore.com"
    s.author = {"Srinivas Vasadi" => "srinivas.vasadi@kore.com"}
    s.source = {:git => "https://github.com/Koredotcom/iOS-kore-sdk.git"}
    s.requires_arc = true

    s.source_files = "KoreBotSDK/Library/KoreBotSDK/KoreBotSDK/**/*.{h,m,swift}"
    s.public_header_files = 'KoreBotSDK/Library/KoreBotSDK/KoreBotSDK/KoreBotSDK.h'

    s.ios.deployment_target = '9.0'

    s.exclude_files = "KoreBotSDK/Library/KoreBotSDK/KoreBotSDK/KoreBotSDK.{h}"
    s.exclude_files = "KoreBotSDK/KoreBotSDKDemo/*.{*}"
    s.exclude_files = "KoreBotSDK/Library/SpeechToText/*.{*}"
    s.exclude_files = "KoreBotSDK/Library/TextParser/*.{*}"
    s.exclude_files = "KoreBotSDK/Library/Widgets/*.{*}"

    s.subspec 'Bot' do |ss|
        ss.ios.deployment_target = '9.0'
        ss.source_files = 'KoreBotSDK/Library/KoreBotSDK/KoreBotSDK/**/*.{h,m,swift}'
        ss.public_header_files = 'KoreBotSDK/KoreBotSDK.h'

        ss.dependency 'Mantle', '2.1.0'
        ss.dependency 'AFNetworking', '3.2.0'
        ss.dependency 'SocketRocket'

        ss.ios.frameworks = 'SystemConfiguration'
    end

    s.subspec 'Widgets' do |ss|
        ss.ios.deployment_target = '9.0'
        ss.source_files = 'KoreBotSDK/Library/Widgets/Widgets/**/*.{h,m,txt,swift,xib}'
        ss.public_header_files = 'KoreBotSDK/Widgets.h'
        ss.resource_bundles = {
            'Widgets' => ['KoreBotSDK/Library/Widgets/Widgets/**/*.xib']
        }
        #ss.exclude_files = "KoreBotSDK/Library/Widgets/Widgets/Controllers/*.{swift}"
        #ss.exclude_files = "KoreBotSDK/Library/Widgets/Widgets/AppDelegate.{h}"
        #ss.exclude_files = "KoreBotSDK/Library/Widgets/Widgets/*.{*}"

        ss.dependency 'AFNetworking', '3.2.0'

        ss.ios.frameworks = 'SystemConfiguration'
    end
end
