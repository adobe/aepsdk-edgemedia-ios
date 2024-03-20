platform :ios, '12.0'

# Comment the next line if you don't want to use dynamic frameworks
use_frameworks!

workspace 'AEPEdgeMedia'
project 'AEPEdgeMedia.xcodeproj'

pod 'SwiftLint', '0.52.0'

def core_pods
  pod 'AEPCore'
end

def edge_pods
  pod 'AEPEdge'
  pod 'AEPEdgeIdentity'
end

target 'AEPEdgeMedia' do
  core_pods
end

target 'UnitTests' do
  core_pods
end

target 'FunctionalTests' do
  core_pods
end

target 'IntegrationTests' do
  core_pods
  edge_pods
end

target 'TestAppiOS' do
  core_pods
  edge_pods
  pod 'AEPAssurance', :git => 'https://github.com/adobe/aepsdk-assurance-ios.git', :branch => 'staging'
end

target 'TestApptvOS' do
  core_pods
  edge_pods
end

post_install do |pi|
  pi.pods_project.targets.each do |t|
    t.build_configurations.each do |bc|
        bc.build_settings['TVOS_DEPLOYMENT_TARGET'] = '12.0'
        bc.build_settings['SUPPORTED_PLATFORMS'] = 'iphoneos iphonesimulator appletvos appletvsimulator'
        bc.build_settings['TARGETED_DEVICE_FAMILY'] = "1,2,3"
    end
  end
end
