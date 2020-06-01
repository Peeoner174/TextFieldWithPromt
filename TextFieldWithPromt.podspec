Pod::Spec.new do |s|
    s.platform = :ios
    s.ios.deployment_target = '13.0'
    s.name = "TextFieldWithPromt"
    s.summary = "TextField and TextView with an Android-style placeholder. TextField also support input-mask and input-mask with template"
    s.requires_arc = true
    s.version = "1.0.0"
    s.license = { :type => "MIT", :file => "LICENSE" }
    s.author = { "Pavel Kochenda" => "peeoner174@gmail.com" }
    s.homepage = "https://github.com/Peeoner174/TextFieldWithPromt"
    s.source = { :git => "https://github.com/Peeoner174/TextFieldWithPromt.git",
    :tag => "#{s.version}" }
    s.framework = "UIKit"
    s.source_files = "TextFieldWithPromt/**/*.{swift}"
    s.resources = "TextFieldWithPromt/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"
    s.swift_version = "5.0"
end
