Pod::Spec.new do |s|
  s.name = 'Wolf'
  s.version = '0.7.1'
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
  s.subspec 'Unbox' do |unbox|
    unbox.source_files = ['Wolf/Classes/**/*']
    unbox.dependency 'Alamofire', '~> 3.4'
    unbox.dependency 'BrightFutures', '~> 4.1'
    unbox.dependency 'Unbox', '~> 1.9'
    unbox.exclude_files = ['Wolf/Classes/Argo/**/*']
  end
  s.subspec 'Argo' do |argo|
    argo.source_files = ['Wolf/Classes/**/*']
    argo.dependency 'Alamofire', '~> 3.4'
    argo.dependency 'BrightFutures', '~> 4.1'
    argo.dependency 'Argo', '~> 3.1'
    argo.exclude_files = ['Wolf/Classes/Unbox/**/*']
  end
  s.default_subspec = 'Unbox'
end
