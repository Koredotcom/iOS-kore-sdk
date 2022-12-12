Pod::Spec.new do |s|
    s.name = "KoreWidgets"
    s.version = "0.0.1"
    s.summary = "KoreWidgets"
    s.homepage = "https://kore.com"

    s.license = "MIT (KoreWidgets)"
    s.license  = {:type => "MIT", :file => "LICENSE" }

    s.platform = :ios
    s.platform = :ios, "8.0"

    s.author = {"Srinivas Vasadi" => "srinivas.vasadi@kore.com"}

    s.source = {:git => "https://github.com/Koredotcom/iOS-kore-sdk.git"}

    s.source_files = "Widgets/**/*.{h,m,txt,swift,xib}"
    s.resource_bundles = {
    'KoreWidgets' => ['Widgets/**/*.xib']
    }
#s.exclude_files = "Widgets/Controllers/*.{swift}"
#s.exclude_files = "Widgets/AppDelegate.{h}"
#s.exclude_files = "Widgets/Widgets/*.{*}"

    s.dependency 'AFNetworking', '2.5.4'
    s.framework = 'SystemConfiguration'
    s.requires_arc = true
end
