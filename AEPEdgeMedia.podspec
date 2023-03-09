Pod::Spec.new do |s|
  s.name             = "AEPEdgeMedia"
  s.version          = "1.0.0-beta"
  s.summary          = "Experience Platform Edge Media extension for Adobe Experience Platform Mobile SDK. Written and maintained by Adobe."

  s.description      = <<-DESC
                       The Experience Platform Edge Media extension enables handling Media Analytics using Adobe Edge Network.
                       DESC

  s.homepage         = "https://github.com/adobe/aepsdk-edgemedia-ios.git"
  s.license          = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.author           = "Adobe Experience Platform SDK Team"
  s.source           = { :git => "https://github.com/adobe/aepsdk-edgemedia-ios.git", :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.tvos.deployment_target = '10.0'

  s.swift_version = '5.1'

  s.pod_target_xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES' }
  s.dependency 'AEPCore', '>= 3.7.0'
  s.dependency 'AEPEdge', '>= 1.6.0'
  s.source_files = 'Sources/**/*.swift'
end
