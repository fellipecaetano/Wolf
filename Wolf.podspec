Pod::Spec.new do |s|
  s.name = 'Wolf'
  s.version = '0.8.2'
  s.summary = 'An opinionated, protocol-oriented networking layer.'
  s.description = <<-DESC
Wolf approaches networking by bringing together the battle experience of Alamofire and the flexible power of Swift protocols.
                  DESC
  s.homepage = 'https://github.com/fellipecaetano/Wolf'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'Fellipe Caetano' => 'fellipe.caetano4@gmail.com' }
  s.source = { :git => 'https://github.com/fellipecaetano/Wolf.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'
  s.requires_arc = true
  s.subspec 'Basic' do |ss|
    ss.source_files = ['Wolf/Classes/**/*']
    ss.dependency 'Alamofire', '~> 3.4'
    ss.dependency 'BrightFutures', '~> 4.1'
    ss.exclude_files = ['Wolf/Classes/Argo/**/*', 'Wolf/Classes/Unbox/**/*']
  end
  s.subspec 'Unbox' do |ss|
    ss.source_files = ['Wolf/Classes/**/*']
    ss.dependency 'Alamofire', '~> 3.4'
    ss.dependency 'BrightFutures', '~> 4.1'
    ss.dependency 'Unbox', '~> 1.9'
    ss.exclude_files = ['Wolf/Classes/Argo/**/*']
  end
  s.subspec 'Argo' do |ss|
    ss.source_files = ['Wolf/Classes/**/*']
    ss.dependency 'Alamofire', '~> 3.4'
    ss.dependency 'BrightFutures', '~> 4.1'
    ss.dependency 'Argo', '~> 3.1'
    ss.exclude_files = ['Wolf/Classes/Unbox/**/*']
  end
  s.default_subspec = 'Basic'
end
