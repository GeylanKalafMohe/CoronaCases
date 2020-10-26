# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'CoronaCases' do
  # Comment the next line if you don't want to use dynamic frameworks
  # use_frameworks!

  # Pods for CoronaCases
pod 'IHKeyboardAvoiding'
pod 'Firebase/Analytics'
pod 'Firebase/Crashlytics'
pod 'Firebase/Performance'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name.start_with?("Pods")
        puts "Updating #{target.name} to exclude Crashlytics/Fabric"
      target.build_configurations.each do |config|
        xcconfig_path = config.base_configuration_reference.real_path
        xcconfig = File.read(xcconfig_path)
        xcconfig.sub!('-framework "FirebaseAnalytics"', '')
        xcconfig.sub!('-framework "FIRAnalyticsConnector"', '')
        xcconfig.sub!('-framework "Google-Mobile-Ads-SDK"', '')
        xcconfig.sub!('-framework "GoogleAppMeasurement"', '')
        xcconfig.sub!('-framework "FirebasePerformance"', '')
        new_xcconfig = xcconfig + 'OTHER_LDFLAGS[sdk=iphone*] = $(inherited) -framework "FirebaseAnalytics"  -framework "FIRAnalyticsConnector" -framework "GoogleAppMeasurement" "-AppMeasurement" -framework "FirebasePerformance"'
        File.open(xcconfig_path, "w") { |file| file << new_xcconfig }
      end
    end
  end
end

end
