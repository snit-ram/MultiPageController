Pod::Spec.new do |s|
  s.name             = 'MultiPageController'
  s.version          = '0.1.0'
  s.summary          = 'UIPageController-like component that allows fast navigation by horizontal scrolling'


  s.description      = <<-DESC
Component inspired by UIPageController that allows fast navigation by scrolling to switch to a different ViewController. 
ViewControllers are lazily instantiated the first time it gets activated.
An item gets automatically selected if the user stop scrolling, or the user can tap an element o select it.
                       DESC

  s.homepage         = 'https://github.com/snit-ram/MultiPageController'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Rafael Martins' => 'snit.ram@gmail.com' }
  s.source           = { :git => 'https://github.com/snit-ram/MultiPageController.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'MultiPageController/Source/**/*'
end
