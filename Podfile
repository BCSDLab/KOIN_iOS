# Uncomment the next line to define a global platform for your project
# platform :ios, '11.0'

target 'dev_koin' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for dev_koin
  pod 'Alamofire', '~> 4.7'
  pod 'ObjectMapper'
  pod 'AlamofireObjectMapper', '~> 5.2'
  pod 'PKHUD'
  pod 'Japx'
  pod 'Japx/CodableAlamofire'
  pod 'SDWebImageSwiftUI'

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
