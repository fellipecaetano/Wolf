Pod::Spec.new do |s|
  s.name             = 'Wolf'
  s.version          = '0.5.0'
  s.summary          = 'Handy solutions to common iOS app development problems.'

  s.description      = <<-DESC
Wolf brings handy solutions to common iOS app development problems. It includes storyboard management, error handling shortcuts, an opinionated networking layer and more.
                       DESC

  s.homepage = 'https://github.com/fellipecaetano/Wolf'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'Fellipe Caetano' => 'fellipe.caetano4@gmail.com' }
  s.source = { :git => 'https://github.com/fellipecaetano/Wolf.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.requires_arc = true

  s.default_subspec = 'All'

  s.subspec 'All' do |all|
    all.source_files = ['Wolf/Classes/**/*']
    all.dependency 'Alamofire', '~> 3.4'
    all.dependency 'BrightFutures', '~> 4.1'
    all.dependency 'Argo', '~> 3.1'
    all.dependency 'Unbox', '~> 1.9'
  end

  s.subspec 'Standard' do |std|
    std.source_files = ['Wolf/Classes/**/*']
    std.exclude_files = ['Wolf/Classes/Argo/**/*']
    std.dependency 'Alamofire', '~> 3.4'
    std.dependency 'BrightFutures', '~> 4.1'
    std.dependency 'Unbox', '~> 1.9'
  end
end
