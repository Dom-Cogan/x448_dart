Pod::Spec.new do |s|
  s.name             = 'x448_dart'
  s.version          = '0.0.1'
  s.summary          = 'X448DartPlugin'
  s.source           = { :path => '.' }
  s.ios.deployment_target = '11.0'
  s.vendored_libraries = 'libboringssl.a'
end