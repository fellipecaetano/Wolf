Pod::Spec.new do |s|
  s.name             = 'IBentifiers'
  s.version          = '1.2.2'
  s.summary          = 'Handle your identifiable IB elements swiftly.'
  s.description      = <<-DESC
IBentifiers provide swifty shortcuts and extensions that ease handling of identifiable IB elements such as storyboards and NIBs.
                       DESC
  s.homepage         = 'https://github.com/fellipecaetano/IBentifiers'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Fellipe Caetano' => 'fellipe.caetano4@gmail.com' }
  s.source           = { :git => 'https://github.com/fellipecaetano/IBentifiers.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = 'Source/**/*.swift'
end
