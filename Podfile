platform :ios, '10.0'

# Comment the next line if you don't want to use dynamic frameworks
use_frameworks!

workspace 'AEPEdgeMedia'
project 'AEPEdgeMedia.xcodeproj'

pod 'SwiftLint', '0.44.0'

target 'AEPEdgeMedia' do
  pod 'AEPCore'
  pod 'AEPServices'
end

target 'UnitTests' do
  pod 'AEPCore'
  pod 'AEPServices'
end

target 'FunctionalTests' do
  pod 'AEPCore'
  pod 'AEPServices'
end

target 'IntegrationTests' do
  pod 'AEPCore'
  pod 'AEPServices'
  pod 'AEPEdge'
  pod 'AEPEdgeIdentity'
end

target 'TestAppiOS' do
  pod 'AEPCore'
  pod 'AEPEdge'
  pod 'AEPEdgeIdentity'
  pod 'AEPAssurance'
  pod 'AEPServices'
end

target 'TestApptvOS' do
  pod 'AEPCore'
  pod 'AEPServices'
end

post_install do |pi|
  pi.pods_project.targets.each do |t|
    t.build_configurations.each do |bc|
        bc.build_settings['TVOS_DEPLOYMENT_TARGET'] = '10.0'
        bc.build_settings['SUPPORTED_PLATFORMS'] = 'iphoneos iphonesimulator appletvos appletvsimulator'
        bc.build_settings['TARGETED_DEVICE_FAMILY'] = "1,2,3"
    end
  end
end
