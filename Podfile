# Uncomment the next line to define a global platform for your project
 platform :ios, '11.0'

target '微博项目练习' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for 微博项目练习

pod 'SnapKit'
pod 'SDWebImage'
pod 'SVProgressHUD'
pod 'Alamofire'
pod 'FFLabel'

  target '微博项目练习Tests' do
    inherit! :search_paths
    # Pods for testing
      
  end

  target '微博项目练习UITests' do
    # Pods for testing
    
  end

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
               end
          end
   end
end
end

