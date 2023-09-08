Pod::Spec.new do |s|
  s.name        = 'SVGKit'
  s.version     = '3.1.1'
  s.license     = 'MIT'
  s.osx.deployment_target = '11.0'
  s.ios.deployment_target = '11.0'
  s.tvos.deployment_target = '11.0'
  s.summary     = "Display and interact with SVG Images on iOS, using native rendering (CoreAnimation)."
  s.homepage = 'https://github.com/SVGKit/SVGKit'
  s.author   = { 'Steven Fusco'    => 'github@stevenfusco.com',
                 'adamgit'         => 'adam.m.s.martin@gmail.com',
                 'Kevin Stich'     => 'stich@50cubes.com',
                 'Joshua May'      => 'notjosh@gmail.com',
                 'Eric Man'        => 'meric.au@gmail.com',
                 'Matt Rajca'      => 'matt.rajca@me.com',
                 'Moritz Pfeiffer' => 'moritz.pfeiffer@alp-phone.ch' }
  s.source   = { :git => 'https://github.com/SVGKit/SVGKit.git', :tag => s.version.to_s }
  s.source_files = 'Source/*.{h,m}', 'Source/**/*.{h,m}'
  s.exclude_files = 'Source/include/*.h'
  s.private_header_files = 'Source/SVGKDefine_Private.h'
  s.ios.private_header_files = 'Source/AppKit additions/SVGKImageRep.h', 'Source/Exporters/SVGKExporterNSImage.h'
  s.tvos.private_header_files = 'Source/AppKit additions/SVGKImageRep.h', 'Source/Exporters/SVGKExporterNSImage.h'
  s.osx.private_header_files = 'Source/Exporters/SVGKExporterUIImage.h'
  s.libraries = 'xml2'
  s.framework = 'QuartzCore', 'CoreText'
  s.module_map = 'SVGKitLibrary/SVGKit-iOS/SVGKit.modulemap'
  s.requires_arc = true
  s.pod_target_xcconfig = {
    'CLANG_CXX_LANGUAGE_STANDARD' => 'gnu++11',
    'CLANG_CXX_LIBRARY' => 'libc++',
    'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2'
  }
end
