Pod::Spec.new do |s|
s.name             = "JBPersistenceStore"
s.version          = "5.0.0"
s.summary          = "A persistence store for storing your models in a yapdatabase"

s.description      = <<-DESC
A persistence store for storing your models in a yapdatabase.
DESC

s.homepage         = "https://github.com/barteljan/JBPersistenceStore"
s.license          = 'MIT'
s.author           = { "Jan Bartel" => "jan.bartel@atino.net" }
s.source           = { :git => "https://github.com/barteljan/JBPersistenceStore.git", :tag => s.version.to_s }
s.social_media_url = 'https://twitter.com/janbartel'

s.ios.deployment_target = '13.0'
s.swift_version = '4.2'

s.source_files = 'JBPersistenceStore/Classes/**/*'

s.pod_target_xcconfig = { 'WARNING_CFLAGS' => '-Wdeprecated-declarations' }

s.dependency 'YapDatabase/Standard', '~> 3.1.1'
s.dependency 'JBPersistenceStore-Protocols','~> 6.0.0'
s.dependency 'VISPER-Entity', '~> 5.0.0'

end
