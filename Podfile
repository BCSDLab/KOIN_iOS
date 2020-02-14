# Uncomment the next line to define a global platform for your project
# platform :ios, '11.0'

target 'dev_koin' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # use_modular_headers!

  # Pods for dev_koin
  pod 'Alamofire', '~> 5.0.0-rc.3'
  pod 'PKHUD'
  pod 'SDWebImageSwiftUI'
  pod "RichEditorView"
  #pod 'SwiftRichString'
  #pod 'AttributedTextView', '~> 1.4.0'
  pod "WordPress-Aztec-iOS", "1.15" # or the version number you want
  pod "WordPress-Editor-iOS", "1.15"
  pod 'Gridicons', :podspec => 'https://raw.github.com/Automattic/Gridicons-iOS/develop/Gridicons.podspec'
  # pod 'VEditorKit'


end

post_install do |installer|
installer.pods_project.build_configurations.each do |config|
    config.build_settings.delete('CODE_SIGNING_ALLOWED')
    config.build_settings.delete('CODE_SIGNING_REQUIRED')
end

installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
        config.build_settings['CONFIGURATION_BUILD_DIR'] = '$PODS_CONFIGURATION_BUILD_DIR'
    end
end
end
