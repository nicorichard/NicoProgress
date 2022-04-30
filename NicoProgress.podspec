Pod::Spec.new do |s|
  s.name             = 'NicoProgress'
  s.version          = '0.3.0'
  s.summary          = 'Simple linear progress bar for indeterminate and determinate progress'
  s.description      = <<-DESC
"A simple material UI progress bar. For indeterminate and linear progress. Supporting both programmatic and storyboard initialization."
                       DESC
  s.homepage         = 'https://github.com/nicorichard/NicoProgress'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Nicolas Richard' => 'nicorichard@gmail.com' }
  s.source           = { :git => 'https://github.com/nicorichard/NicoProgress.git', :tag => s.version.to_s }
  s.swift_versions   = ['4.0', '4.2', '5.0', '5.2']

  s.ios.deployment_target = '8.0'

  s.source_files = 'Sources/NicoProgress/**/*'
end
