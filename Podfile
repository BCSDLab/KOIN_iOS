# Uncomment the next line to define a global platform for your project
# platform :ios, '13.0'
post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
               end
          end
   end
end
use_frameworks!

target 'koin' do
 pod 'NMapsMap'
 pod 'GoogleUtilities'
 pod 'Alamofire'
pod 'DropDown'
pod 'SnapKit'
pod 'FirebaseMessaging'
pod 'Firebase'
pod 'Firebase/Analytics'
pod 'Moya'
pod 'Then'
pod 'Cosmos'
pod 'Kingfisher'
pod 'KakaoSDKShare'  
pod 'KakaoSDKTemplate'
pod 'SwiftSoup'
end

target 'NotificationService' do
use_frameworks!
pod 'FirebaseMessaging'
pod 'GoogleUtilities'
end
