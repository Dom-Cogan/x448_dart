Pod::Spec.new do |s|
  s.name             = 'x448_dart'
  s.version          = '0.0.1'
  s.summary          = 'Constant-time X448 backend for Flutter'
  s.description      = 'Vendored static library providing constant-time X448 (Curve448) operations for the x448_dart plugin.'
  s.homepage         = 'https://github.com/Dom-Cogan/x448_dart'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Dom Cogan' => 'you@example.com' }
  s.source           = { :path => '.' }

  s.ios.deployment_target = '11.0'
  s.static_framework      = true

  # Your tiny plugin stub (already in repo)
  s.source_files = 'Classes/**/*'

  # The prebuilt static library you uploaded
  s.vendored_libraries = 'VendoredLibraries/libx448dart.a'
end
