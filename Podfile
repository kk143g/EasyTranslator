# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

target 'EasyTranslator' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  # Pods for EasyTranslator
  pod 'GoogleMLKit/LanguageID', '3.2.0'
  pod 'GoogleMLKit/Translate', '3.2.0'
  pod 'SSSwiftUIGIFView'

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      
      if target.name == 'BoringSSL-GRPC'
        target.source_build_phase.files.each do |file|
          if file.settings && file.settings['COMPILER_FLAGS']
            flags = file.settings['COMPILER_FLAGS'].split
            flags.reject! { |flag| flag == '-GCC_WARN_INHIBIT_ALL_WARNINGS' }
            file.settings['COMPILER_FLAGS'] = flags.join(' ')
          end
        end
      end
      
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
        config.build_settings['CODE_SIGN_STYLE'] = "Automatic"
        if config.base_configuration_reference.is_a? Xcodeproj::Project::Object::PBXFileReference
          xcconfig_path = config.base_configuration_reference.real_path
          IO.write(xcconfig_path, IO.read(xcconfig_path).gsub("DT_TOOLCHAIN_DIR", "TOOLCHAIN_DIR"))
        end
      end
      
    end
  end
  
  target 'EasyTranslatorTests' do
    inherit! :search_paths
    # Pods for testing
  end
  
  target 'EasyTranslatorUITests' do
    # Pods for testing
  end
  
end
