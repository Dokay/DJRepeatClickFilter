
Pod::Spec.new do |s|
  s.name             = 'DJRepeatClickFilter'
  s.version          = '0.1.0'
  s.summary          = 'DJRepeatClickFilter is a tool to void strange questions while tap quickly.'

  s.description      = <<-DESC
						A tool to void strange questions while tap quickly.Such as navigation stack error.
                       DESC

  s.homepage         = 'https://github.com/Dokay/DJRepeatClickFilter'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'dokay.dou@gmail.com' => 'dokay.dou@gmail.com' }
  s.source           = { :git => 'https://github.com/Dokay/DJRepeatClickFilter.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'TestClickQuickly/RepeatClick/**/*'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
