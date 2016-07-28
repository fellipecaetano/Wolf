Pod::Spec.new do |s|
  s.name             = 'Wolf'
  s.version          = '0.1.0'
  s.summary          = 'Handy solutions to common app development problems.'

  s.description      = <<-DESC
Handy solutions to common app development problems. It includes storyboard management, error handling shortcuts, an opinionated networking layer and more.
                       DESC

  s.homepage = 'https://github.com/fellipecaetano/Wolf'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'Fellipe Caetano' => 'fellipe.caetano4@gmail.com' }
  s.source = { :git => 'https://github.com/fellipecaetano/Wolf.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.dependency 'Alamofire', '~> 3.4'
  s.dependency 'Argo', '~> 3.0'
  s.source_files = 'Wolf/Classes/**/*'
end
