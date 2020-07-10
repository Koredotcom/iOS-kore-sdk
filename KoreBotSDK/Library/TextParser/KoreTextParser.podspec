Pod::Spec.new do |s|
    s.name = "KoreTextParser"
    s.version = "0.0.1"
    s.summary = "KoreTextParser"
    s.homepage = "https://kore.com"

    s.license = "MIT (KoreTextParser)"
    s.license  = {:type => "MIT", :file => "LICENSE" }

    s.platform = :ios
    s.platform = :ios, "8.0"

    s.author = {"Srinivas Vasadi" => "srinivas.vasadi@kore.com"}
    s.source = {:git => "https://github.com/Koredotcom/iOS-kore-sdk.git"}

    s.source_files = "TextParser/Library/*.{h,m,swift}"
#s.exclude_files = "TextParser/*.{h}"
#s.exclude_files = "TextParser/*.{*}"

    s.framework = 'SystemConfiguration'
    s.requires_arc = true
end
