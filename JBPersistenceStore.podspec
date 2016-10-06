Pod::Spec.new do |s|
  s.name             = "JBPersistenceStore"
  s.version          = "0.2.2"
  s.summary          = "A persistence store for storing your models in a yapdatabase"

  s.description      = <<-DESC
A persistence store for storing your models in a yapdatabase.
                       DESC

  s.homepage         = "https://github.com/barteljan/JBPersistenceStore"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Jan Bartel" => "jan.bartel@atino.net" }
  s.source           = { :git => "https://github.com/barteljan/JBPersistenceStore.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/janbartel'

  s.ios.deployment_target = '8.0'

  s.source_files = 'JBPersistenceStore/Classes/**/*'

  s.dependency 'YapDatabase'
  s.dependency 'ValueCoding','1.5.0'
  s.dependency 'JBPersistenceStore-Protocols'
end
