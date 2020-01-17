Pod::Spec.new do |s|
  s.name             = 'NicoProgress'
  s.version          = '0.1.6'
  s.summary          = 'Simple linear progress bar for indeterminate and determinate progress'
  s.description      = <<-DESC
"A simple material UI progress bar. For indeterminate and linear progress. Supporting both programmatic and storyboard initialization."
                       DESC
  s.homepage         = 'https://github.com/CityTransit/NicoProgress'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Nicolas Richard' => 'nicorichard@gmail.com' }
  s.source           = { :git => 'https://github.com/CityTransit/NicoProgress.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'NicoProgress/Classes/**/*'
end
