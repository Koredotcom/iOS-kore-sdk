Pod::Spec.new do |s|
    s.name = "KoreBotSDK"
    s.version = "0.0.8"
    s.summary = "KoreBotSDK lets a user interact with Kore bots"
    s.homepage = "https://kore.com"

    s.license = "MIT (KoreBotSDK)"
    s.license  = {:type => "MIT", :file => "LICENSE" }

    s.platform = :ios
    s.platform = :ios, "8.0"

    s.author = {"Srinivas Vasadi" => "srinivas.vasadi@kore.com"}
    s.source = {:git => "https://github.com/Koredotcom/iOS-kore-sdk.git"}

    s.source_files = "KoreBotSDK/**/*.{h,m,swift}"
    s.exclude_files = "KoreBotSDK/KoreBotSDK.{h}"
    s.exclude_files = "../../KoreBotSDKDemo/*.{*}"
    s.exclude_files = "../SpeechToText/*.{*}"
    s.exclude_files = "../TextParser/*.{*}"
    s.exclude_files = "../Widgets/*.{*}"


    s.dependency 'Mantle', '2.0.2'
    s.dependency 'AFNetworking', '2.5.4'
    s.dependency 'SocketRocket'

    s.framework = 'SystemConfiguration'
    s.requires_arc = true
end
