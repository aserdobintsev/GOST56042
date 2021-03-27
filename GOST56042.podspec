Pod::Spec.new do |s|
  s.name         = "GOST56042"
  s.version      = "0.9.0"
  s.summary      = "Library for working with Russian Standard GOST R 56042-2014."
  s.description  = <<-DESC
Library for working with Russian Standard "**GOST R 56042-2014** Standards of financial transactions. Two-dimensional barcode symbols for payments by individuals" [ГОСТ Р 56042-2014].
GOST56042 makes it easy to quickly parse data encoded with GOST R 56042-2014.
                   DESC

  s.homepage     = "https://github.com/aserdobintsev/GOST56042"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Alexander Serdobintsev" => "aserdobintsev@gmail.com" }
  s.ios.deployment_target = "10.0"
  s.osx.deployment_target = "10.14"
  s.watchos.deployment_target = "5.0"
  s.tvos.deployment_target = "12.0"
  s.source       = { :git => "https://github.com/aserdobintsev/GOST56042.git", :tag => s.version.to_s }
  s.source_files = "Sources/GOST56042/**/*.{h,m,swift}"
  s.swift_version = '5.3'
end
