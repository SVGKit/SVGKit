Pod::Spec.new do |s|
  s.name        = 'SVGKit'
  s.version     = '2.x'
  s.license     = 'MIT'
  s.platform    = :ios, '6.0'
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
                 'Eric Man'        => 'Eric@eric-mans-macbook-2.local',
                 'C.W. Betts'      => 'computers57@hotmail.com' }
  s.source   = { :git => 'https://github.com/MaddTheSane/SVGKit.git', :branch => "cleanup" }

  s.ios.source_files = 'Source/*{.h,m}', 'Source/DOM classes/**/*.{h,m}', 'Source/Exporters/*.{h,m}', 'Source/Parsers/**/*.{h,m}', 'Source/QuartzCore additions/**/*.{h,m}', 'Source/Sources/**/*.{h,m}', 'Source/UIKit additions/**/*.{h,m}', 'Source/Unsorted/**/*.{h,m}'
  s.libraries = 'xml2'
  s.framework = 'QuartzCore', 'CoreText'
  s.dependency 'CocoaLumberjack'
  s.prefix_header_file = 'XCodeProjectData/SVGKit-iOS/SVGKit-iOS-Prefix.pch'
  s.requires_arc = true
  s.xcconfig = {
    'CLANG_CXX_LANGUAGE_STANDARD' => 'gnu++11',
    'CLANG_CXX_LIBRARY' => 'libc++',
    'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2'
  }
end
