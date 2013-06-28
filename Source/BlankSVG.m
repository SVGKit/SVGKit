//
//  BlankSVG.m
//  SVGKit-OSX
//
//  Created by C.W. Betts on 6/16/13.
//  Copyright (c) 2013 C.W. Betts. All rights reserved.
//

#import "BlankSVG.h"

#undef SVGKsvgStringDefaultContents

/**
 ************* NB: it is critical that the string we're about to create is NOT INDENTED - the tabs would break the parsing!
 */

static NSString* const SVGKsvgStringDefaultContents = @"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n\
\n\
<svg \
xmlns:svg=\"http://www.w3.org/2000/svg\" \
xmlns=\"http://www.w3.org/2000/svg\" \
width=\"100\" \
height=\"100\" \
id=\"svg2\" \
version=\"1.1\"> \
<defs \
id=\"defs4\" /> \
<metadata \
id=\"metadata7\"> \
</metadata> \
<g \
id=\"layer1\" \
transform=\"translate(0,-952.36218)\"> \
<rect \
style=\"opacity:0.98000003999999996;color:#000000;fill:#bf01ff;fill-opacity:0.99607843;fill-rule:nonzero;stroke:none;stroke-width:3;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate\" \
id=\"rect2985\" \
width=\"100\" \
height=\"100\" \
x=\"0\" \
y=\"952.36218\" /> \
<text \
xml:space=\"preserve\" \
style=\"font-size:40px;font-style:normal;font-weight:normal;line-height:125%;letter-spacing:0px;word-spacing:0px;fill:#f6ff0f;fill-opacity:1;stroke:none;font-family:Sans\" \
x=\"6.3190379\" \
y=\"991.14648\" \
id=\"text3755\" \
><tspan \
x=\"6.3190379\" \
y=\"991.14648\" \
id=\"tspan3759\" \
style=\"font-size:24px;fill:#f6ff0f;fill-opacity:1\">Missing</tspan></text> \
<text \
xml:space=\"preserve\" \
style=\"font-size:40px;font-style:normal;font-weight:normal;line-height:125%;letter-spacing:0px;word-spacing:0px;fill:#fffc45;fill-opacity:1;stroke:none;font-family:Sans\" \
x=\"26.460968\" \
y=\"1030.2456\" \
id=\"text3763\" \
><tspan \
id=\"tspan3765\" \
x=\"26.460968\" \
y=\"1030.2456\" \
style=\"font-size:24px;fill:#fffc45;fill-opacity:1\">SVG</tspan></text> \
</g> \
</svg>";


NSString* const SVGKGetConstantStringDefaultContents()
{
	return SVGKsvgStringDefaultContents;
}
