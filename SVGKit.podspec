Pod::Spec.new do |s|
  s.name        = 'SVGKit'
  s.version     = '2.0.0'
  s.license     = 'MIT'
  s.platform    = :ios, '5.0'
  s.summary     = "Display and interact with SVG Images on iOS, using native rendering (CoreAnimation)."
  s.homepage = 'https://github.com/SVGKit/SVGKit'
  s.author   = { 'Steven Fusco'    => 'github@stevenfusco.com',
                 'adamgit'         => 'adam.m.s.martin@gmail.com',
                 'Kevin Stich'     => 'stich@50cubes.com',
                 'Joshua May'      => 'notjosh@gmail.com',
                 'Eric Man'        => 'meric.au@gmail.com',
                 'Matt Rajca'      => 'matt.rajca@me.com',
                 'Moritz Pfeiffer' => 'moritz.pfeiffer@alp-phone.ch',
                 'Steven Fusco'    => 'sfusco@spiral.local',
                 'Eric Man'        => 'Eric@eric-mans-macbook-2.local' }
  s.source   = { :git => 'https://github.com/SVGKit/SVGKit.git', :branch => "2.x" }

  s.ios.source_files = 'Source/*{.h,m}', 'Source/DOM classes/**/*.{h,m}', 'Source/Exporters/*.{h,m}', 'Source/Parsers/**/*.{h,m}', 'Source/QuartzCore additions/**/*.{h,m}', 'Source/Sources/**/*.{h,m}', 'Source/UIKit additions/**/*.{h,m}', 'Source/Unsorted/**/*.{h,m}'
  s.tvos.deployment_target = '9.0'
  s.libraries = 'xml2'
  s.framework = 'QuartzCore', 'CoreText'
  s.dependency 'CocoaLumberjack', '~> 2.x'
  s.prefix_header_file = 'SVGKitLibrary/SVGKit-iOS/SVGKit-iOS-Prefix.pch'
  s.requires_arc = true
  s.xcconfig = {
    'CLANG_CXX_LANGUAGE_STANDARD' => 'gnu++11',
    'CLANG_CXX_LIBRARY' => 'libc++',
    'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2'
  }
end
