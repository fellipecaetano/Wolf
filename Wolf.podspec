Pod::Spec.new do |s|
  s.name = 'Wolf'
  s.version = '0.6.0'
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
  s.requires_arc = true
  s.subspec 'Unbox' do |unbox|
    configure_subspec(unbox)
    unbox.exclude_files = ['Wolf/Classes/Argo/**/*']
  end
  s.subspec 'Argo' do |argo|
    configure_subspec(argo)
    argo.exclude_files = ['Wolf/Classes/Unbox/**/*']
  end
  s.default_subspec = 'Unbox'
end

def configure_subspec(subspec)
  subspec.source_files = ['Wolf/Classes/**/*']
  subspec.dependency 'Alamofire', '~> 3.4'
  subspec.dependency 'BrightFutures', '~> 4.1'
end
