Pod::Spec.new do |s|
  s.name             = 'Wolf'
  s.version          = '0.1.0'
  s.summary          = 'Handy solutions to common app development problems.'

  s.description      = <<-DESC
Wolf brings handy solutions to common app development problems. It includes storyboard management, error handling shortcuts, an opinionated networking layer and more.
                       DESC

  s.homepage = 'https://github.com/fellipecaetano/Wolf'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'Fellipe Caetano' => 'fellipe.caetano4@gmail.com' }
  s.source = { :git => 'https://github.com/fellipecaetano/Wolf.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.requires_arc = true

  s.subspec 'All' do |all|
    all.source_files = ['Wolf/Classes/**/*']
    all.dependency 'Alamofire', '~> 3.4'
    all.dependency 'Argo', '~> 3.1'
  end

  s.subspec 'Storyboards' do |all|
    all.source_files = ['Wolf/Classes/Storyboards/**/*']
  end

  s.subspec 'Reuse' do |reuse|
    reuse.source_files = ['Wolf/Classes/Reuse/**/*']
  end

  s.subspec 'Networking' do |networking|
    networking.source_files = ['Wolf/Classes/Networking/**/*']
    networking.dependency 'Alamofire', '~> 3.4'
  end

  s.subspec 'Argo' do |argo|
    argo.source_files = ['Wolf/Classes/Networking/**/*', 'Wolf/Classes/Argo/**/*']
    argo.dependency 'Alamofire', '~> 3.4'
    argo.dependency 'Argo', '~> 3.1'
  end

  s.default_subspec = 'All'
end
