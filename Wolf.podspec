Pod::Spec.new do |s|
  s.name = 'Wolf'
  s.version = '2.1.4'
  s.summary = 'An opinionated, protocol-oriented networking layer.'
  s.description = <<-DESC
Wolf approaches networking by bringing together the battle experience of Alamofire and the flexible power of Swift protocols.
                  DESC
  s.homepage = 'https://github.com/fellipecaetano/Wolf'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'Fellipe Caetano' => 'fellipe.caetano4@gmail.com' }
  s.source = { :git => 'https://github.com/fellipecaetano/Wolf.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.requires_arc = true
  s.subspec 'Basic' do |ss|
    ss.source_files = ['Source/**/*.swift']
    ss.dependency 'Alamofire', '~> 4.1'
    ss.dependency 'PromiseKit', '~> 4.0'
    ss.exclude_files = ['Source/Unbox/**/*']
  end
  s.subspec 'Unbox' do |ss|
    ss.source_files = ['Source/**/*.swift']
    ss.dependency 'Alamofire', '~> 4.1'
    ss.dependency 'PromiseKit', '~> 4.0'
    ss.dependency 'Unbox', '~> 2.2'
  end
  s.default_subspec = 'Basic'
end
