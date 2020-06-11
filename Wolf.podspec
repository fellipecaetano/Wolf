Pod::Spec.new do |s|
  s.name = 'Wolf'
  s.version = '4.0.0'
  s.summary = 'An opinionated, protocol-oriented networking layer.'
  s.description = <<-DESC
Wolf approaches networking by bringing together the battle experience of Alamofire and the flexible power of Swift protocols.
                  DESC
  s.homepage = 'https://github.com/fellipecaetano/Wolf'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'Fellipe Caetano' => 'fellipe.caetano4@gmail.com' }
  s.source = { :git => 'https://github.com/fellipecaetano/Wolf.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'
  s.requires_arc = true
  s.subspec 'Basic' do |ss|
    ss.source_files = ['Source/**/*.swift']
    ss.dependency 'Alamofire', '~> 4.9.1'
    ss.dependency 'PromiseKit', '~> 6.13.1'
  end
  s.default_subspec = 'Basic'
end
