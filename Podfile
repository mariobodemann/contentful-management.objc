plugin 'cocoapods-keys', {
  :project => 'ManagementSDK',
  :keys => [ 'ManagementAPIAccessToken' ]
}

source 'https://github.com/CocoaPods/Specs.git'

pod "ContentfulManagementAPI", :path => "."
pod "AFNetworking", :inhibit_warnings => true

target 'Tests', :exclusive => true do
  pod 'Specta'
  pod 'Expecta'
  pod 'CCLRequestReplay', :git => 'https://github.com/neonichu/CCLRequestReplay.git'
end

post_install do |installer_or_rep|
  # Support both CP 0.36.1 and >= 0.38
  installer = installer_or_rep.respond_to?(:installer) ? installer_or_rep.installer : installer_or_rep

  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
    	if not config.build_settings['FRAMEWORK_SEARCH_PATHS']
    		config.build_settings['FRAMEWORK_SEARCH_PATHS'] = ['$(inherited)']
      end

      config.build_settings['FRAMEWORK_SEARCH_PATHS'] << '"$(PLATFORM_DIR)/Developer/Library/Frameworks"'
    end
  end
end
