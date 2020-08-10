Pod::Spec.new do |s|
    s.name = "SpeechToText"
    s.version = "0.0.1"
    s.summary = "SpeechToText"
    s.homepage = "https://kore.com"

    s.license = "MIT (SpeechToText.h)"
    s.license  = {:type => "MIT", :file => "LICENSE" }

    s.platform = :ios
    s.platform = :ios, "8.0"

    s.author = {"Shylaja Mamidala" => "shylaja.mamidala@kore.com"}
    s.source = {:git => "https://github.com/Koredotcom/iOS-kore-sdk.git"}

    s.source_files = "SpeechToText/**/**/*.{h,m}"
    s.exclude_files = "SpeechToText/SpeechToText.{h}"

    s.dependency 'AFNetworking', '2.5.4'
    s.dependency 'SocketRocket'

    s.framework = 'AVFoundation'
    s.requires_arc = true
end
