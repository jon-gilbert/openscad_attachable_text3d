// LibFile: attachable_text3d.scad 
//   OpenSCAD module for creating blocks of 3D text that are attachable with BOSL2. 
//   .
//   OpenSCAD provides a rudimentary [`text()` built-in function](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Text), 
//   but only for 2D models. [BOSL2](https://www.github.com/revarbat/BOSL2/) takes that a step further, and provides 
//   a [`text3d()` module](https://github.com/revarbat/BOSL2/wiki/shapes3d.scad#module-text3d), and those models may be 
//   attached to other BOSL2 attachable primatives. This attachability limitation is because 
//   post hoc dimension information of models within OpenSCAD is not available, and BOSL2 leverages the built-in `text()` to create 
//   `text3d()` models.
//   So, while you can attach text to a shape, you cannot attach a shape to text, nor can you attach text to text. BOSL2 
//   doesn't have the dimensioning information to know how to position objects onto text models which, you know, 
//   that's fair: OpenSCAD *itself* doesn't know what the dimensions of text models are. 
//   Therefore, you can only attach text to other shapes with a known geometry, like this:
//   ```
//   cube([20, 20, 5])
//      attach(TOP, BOTTOM)
//         text3d("x");
//   ```
// Figure(3D,Medium,NoAxes,NoScales):
//   include <BOSL2/std.scad>
//   cube([20, 20, 5])
//      attach(TOP, BOTTOM)
//         text3d("x");
//
// Continues:
//   You can't reverse that order; and, you can't attach models created with `text3d()` to other text models created 
//   similarly.
//   .
//   Circa 2018, [Alexander Pruss](https://www.thingiverse.com/arpruss/designs) took a subset of the available 
//   fonts within OpenSCAD and measured their output, then 
//   consolidated those measurements into a library called [fontmetrics](https://www.thingiverse.com/thing:3004457). This 
//   library provides fairly accurate per-character dimensions for a variety of font faces and styles, and at various sizes,
//   with the intention of providing decent word-wrapping text modules. A side effect of those modules is the availability 
//   of a `measureTextBounds()` function, which does precisely what it's named: given some text and optionally a font 
//   and a sizing, return a bounding dimension. 
//   .
//   **The `attachable_text3d.scad` library - this file - marries BOSL2 bi-directional attachability and `fontmetrics.scad`-measured text 
//   dimensions into a set of modules that produce attachable 3D text:** that is, modeled 3D objects that can use BOSL2's 
//   [attachments](https://github.com/revarbat/BOSL2/wiki/attachments.scad) functionality to join text to other text, arbitrary 
//   shapes, or existing attachment-aware models.
//
// Figure(3D,Medium,NoAxes,NoScales): anchorable, attachable text:
//   include <BOSL2/std.scad>
//   include <attachable_text3d.scad>
//   attachable_text3d("text") show_anchors();
//
// Continues:
//   `attachable_text3d()` and its ilk create an attachable rectangle around the output of `text3d()`, by measuring the size of the 
//   text being fed into `text3d()` and then wrapping that model with `attachable()` using that boundary sizing. 
//   This means you can reverse the above operation that attaches text to things, and instead attach things to text, like so:
//   ```
//   attachable_text3d("x")
//      attach(BOTTOM, TOP)
//         cube([20, 20, 5]);
//   ```
// Figure(3D,Medium,NoAxes,NoScales):
//   include <BOSL2/std.scad>
//   include <attachable_text3d.scad>
//   attachable_text3d("x")
//      attach(BOTTOM, TOP)
//         cube([20, 20, 5]);
//
// Continues:
//   It also means you can join blocks of text with other blocks, as though they were simple BOSL2 rectangles:
//   ```
//   attachable_text3d("z", font="Webdings")
//       attach(RIGHT, LEFT, overlap=-2)
//           attachable_text3d("No Smoking");
//   ```
// Figure(3D,Medium,NoAxes,NoScales):
//   include <BOSL2/std.scad>
//   include <attachable_text3d.scad>
//   attachable_text3d("z", font="Webdings")
//       attach(RIGHT, LEFT, overlap=-2)
//           attachable_text3d("No Smoking");
//
// Includes:
//   include <BOSL2/std.scad>
//   include <attachable_text3d.scad>
// Continues:
//    You must additionally have the `fontmetrics.scad` and `fontmetricsdata.scad`
//    libraries by Alexander Pruss installed. Source these from
//    https://www.thingiverse.com/thing:3004457. 
//    These libraries are available under a CC-BY-4.0 license. 
//

/// We include fontmetricsdata.scad as well as use-ing 
/// fontmetrics.scad to get direct access to its 
/// FONTS list; we use that within _fontmetricsdata_list_fonts().
include <fontmetricsdata.scad>
use <fontmetrics.scad>



// Section: Attachable Text Modules
//
// Module: attachable_text3d()
// Usage:
//   attachable_text3d(text);
//   attachable_text3d(text, <font="Liberation Sans">, <size=10>, <h=1>, <pad=0>, <align=LEFT>, <spacing=1>, <direction="ltr">, <language="en">, <script="latin">, <anchor=CENTER>, <spin=0>, <orient=UP>);
//
// Description:
//   Given a string of text `text`, or a list of strings, create a single 
//   3D model of that text. The resulting model will have BOSL2 attachable anchor points on it, 
//   and can be positioned and attached to as needed. 
//   .
//   `font` must be a font-name and style listed in `AT3D_ATTACHABLE_FONTS`,  because those are the 
//   fonts for which accurate measurements are available. Font families, or families and styles, may be 
//   specified; examples: `font="Times New Roman"`, `font="Liberation Serif:style=Italic"`, `font="Arial:style=Bold Italic"`. 
//   When not specified, `font` defaults to whatever `AT3D_DEFAULT_FONT` is set. 
//   .
//   All text is by default aligned to the left. Horizontal alignment can be adjusted by setting `align` to one of 
//   `LEFT`, `CENTER`, or `RIGHT`. 
//   .
//   The anchor bounding box constructed for the text is as wide as the longest single 
//   text element; and, as deep as the sum of text heights of each text element; and, the 
//   height of `h` used. The bounding box for all strings represented within `text`
//   can be exposed by setting `debug_bounding` to `true`.
//
// Arguments:
//   text = A text string to produce a model of. No default.
//   ---
//   font = The name and style of the font to use. Default: `Liberation Sans`
//   size = The font size to produce text at. Default: `10`
//   h = The height (thickness) of the text produced. Default: `1`
//   line_spacing = Sets the spacing between individual lines of text; this is similar (but not identical) to leading. Default: `0.5`
//   pad = Padding applied to the boundary anchor box surrounding the generated text. Default: `0`
//   align = Horizontally align text to one of `LEFT`, `CENTER`, or `RIGHT`. Default: `LEFT`
//   spacing = The relative spacing multiplier between characters. Default: `1`
//   direction = The text direction. `ltr` for left to right. `rtl` for right to left. `ttb` for top to bottom. `btt` for bottom to top. Default: `ltr`
//   language = The language the text is in. Default: `en`
//   script = The script the text is in. Default: `latin`
//   debug_bounding = If set to `true`, the text model's bounding box will be inscribed around the produced text. Default: `false`
//   anchor = Translate so anchor point is at origin `[0,0,0]`. Default: `CENTER`
//   spin = Rotate this many degrees around the Z axis after anchoring. Default: `0`
//   orient = Vector direction to which the model should point after spin. Default: `UP`
//
// Named Anchors: In addition to the cardinal anchor points provided by BOSL2, `attachable_text3d()` vends the following six additional named anchors:
//   text-left-back = The back-left most corner, oriented backwards
//   text-left-fwd = The forward-left most corner, oriented forwards
//   text-center-back = The back-center face, oriented backwards
//   text-center-fwd = The forward-center face, oriented forwards
//   text-right-back = The top-right most corner, oriented backwards
//   text-right-fwd = The forward-right most corner, oriented forwards
// Figure: Available named anchors:
//   v = "Lorem"; 
//   expose_anchors() attachable_text3d(v) show_anchors(std=false);
//
// Example: A single line of attachable text:
//   attachable_text3d("Lorem Ipsum");
//
// Example: Multiple lines of attachable text; these all are a single attachable model
//   attachable_text3d(["Lorem ipsum dolor sit amet,", 
//      "consectetur adipiscing elit", 
//      "sed do eiusmod tempor incididunt", 
//      "ut labore et dolore magna aliqua."]);
//
// Example: attaching multiple text blocks together:
//   attachable_text3d("Block 1")
//     attach(RIGHT, LEFT)
//        attachable_text3d(", and ")
//           attach(RIGHT, LEFT)
//              attachable_text3d("Block 2");
//
// Example: non-default fonts and sizes:
//   attachable_text3d("Be Alert", font="Verdana:style=Bold", size=15)
//      attach("text-left-fwd", "text-left-back")
//         attachable_text3d(["The world needs", "more Lerts."], font="Verdana", size=10);
//
// Todo:
//   There are no vertical alignment options. I'm not thinking of CSS-level of alignment options, just the basic "bottom/center/top" would do. 
//
module attachable_text3d(texts, font=AT3D_DEFAULT_FONT, size=AT3D_DEFAULT_SIZE, h=AT3D_DEFAULT_HEIGHT, line_spacing=AT3D_DEFAULT_LINE_SPACING, pad=AT3D_DEFAULT_PAD, align=LEFT, spacing=AT3D_DEFAULT_SPACING, direction=AT3D_DEFAULT_DIRECTION, language=AT3D_DEFAULT_LANGUAGE, script=AT3D_DEFAULT_SCRIPT, debug_bounding=false, anchor=AT3D_DEFAULT_ANCHOR, spin=AT3D_DEFAULT_SPIN, orient=AT3D_DEFAULT_ORIENT) {    
    assert(is_string(texts) || is_list(texts));
    assert(in_list(font, AT3D_ATTACHABLE_FONTS));
    assert(size > 0);
    assert(h > 0);
    assert(line_spacing >= 0);
    assert(pad >= 0);
    assert(in_list(align, [LEFT, CENTER, RIGHT]));

    texts_ = (is_list(texts)) ? texts : [texts];
    
    boundary = attachable_text3d_boundary(texts_, font=font, size=size, h=h, line_spacing=line_spacing, pad=pad, spacing=spacing);

    firstline_boundary = attachable_text3d_boundary(texts_[0], font=font, size=size, h=h, pad=pad, spacing=spacing);

    anchors = attachable_text3d_anchors_from_boundary(boundary);

    attachable(anchor, spin, orient, size=boundary, anchors=anchors) {
        union() {
            translate([
                (in_list(align, [LEFT, CENTER]))
                    ? -1 * (boundary.x * ((align == LEFT) ? 0.5 : 0))
                    :  1 * (boundary.x * 0.5),
                0 - (firstline_boundary.y / 2) + (boundary.y / 2),
                0])
                    for (i = idx(texts_)) 
                        let(
                            prevbounds = (i > 0) 
                                ? attachable_text3d_boundary(select(texts_, 0, i - 1), font=font, size=size, h=h, line_spacing=line_spacing, pad=pad, spacing=spacing) 
                                : [0, 0, 0]
                            )
                        fwd(prevbounds.y)
                            _attachable_text3d_one_line(texts_[i], font=font, size=size, h=h, pad=pad, spacing=spacing, direction=direction, language=language, script=script, anchor=align);

            if (debug_bounding)
                translate([-1 * (boundary.x/2), -1 * (boundary.y/2), -1 * (boundary.z/2)])
                    _bounds_debugging(boundary);
        }
        children();
    }
}


/// Module: _attachable_text3d_one_line()
/// Usage:
///   _attachable_text3d_one_line(text);
///   _attachable_text3d_one_line(text, <font="Lucidia Sans">, <size=10>, <h=1>, <pad=0>, <debug_bounding=false>, <anchor=CENTER>, <spin=0>, <orient=UP>);
/// Description:
///   Given a single line of text `text`, and optionally font / sizing specs, create a 3d  
///   model for that text. Includes padding,  
///   font dimensions at the given size. Does NOT include line spacing. model is attachable with 
///   extra anchors.
module _attachable_text3d_one_line(text, font=AT3D_DEFAULT_FONT, size=AT3D_DEFAULT_SIZE, h=AT3D_DEFAULT_HEIGHT, pad=AT3D_DEFAULT_PAD, spacing=AT3D_DEFAULT_SPACING, direction=AT3D_DEFAULT_DIRECTION, language=AT3D_DEFAULT_LANGUAGE, script=AT3D_DEFAULT_SCRIPT, debug_bounding=false, anchor=LEFT, spin=AT3D_DEFAULT_SPIN, orient=AT3D_DEFAULT_ORIENT) {
    assert(is_string(text));
    assert(in_list(font, AT3D_ATTACHABLE_FONTS));
    assert(size > 0);
    assert(h > 0);
    assert(pad >= 0);

    boundary = attachable_text3d_boundary([text], font=font, size=size, h=h, pad=pad, spacing=spacing);
    anchors = attachable_text3d_anchors_from_boundary(boundary);

    attachable(anchor, spin, orient, size=boundary, anchors=anchors) {
        translate( [-1 * (boundary.x/2), -1 * (boundary.y / 2), -1 * (boundary.z / 2) ] )
            union() {
                text3d(text, font=font, size=size, h=h, spacing=spacing, direction=direction, language=language, script=script);
                if (debug_bounding)
                     _bounds_debugging(boundary);
            }
        children();
    }
}


/// Module: _bounds_debugging()
/// Description:
///   Given a set of rectangular boundary coordinates as a list `bounds`, 
///   create a magenta-colored translucent wireframe that shows where 
///   those bounds are. 
module _bounds_debugging(bounds, color="magenta", alpha=0.5, anchor=AT3D_DEFAULT_ANCHOR, spin=AT3D_DEFAULT_SPIN, orient=AT3D_DEFAULT_ORIENT) {
    anchors = attachable_text3d_anchors_from_boundary(bounds);
    attachable(anchor, spin, orient, size=bounds, anchors=anchors) {
        color(color, alpha=alpha)
            vnf_wireframe(cube(bounds), width=0.2);
        children();
    }
}


// Section: Boundary Functions
//
//
//
// Function: attachable_text3d_boundary()
// Usage:
//   boundary = attachable_text3d_boundary(text);
//   boundary = attachable_text3d_boundary(texts);
//   boundary = attachable_text3d_boundary(texts, <font="Liberation Sans">, <size=10>, <h=1>, <line_spacing=0.5>, <pad=0>);
//
// Description:
//   Given a list of strings `texts`, calculate the boundary sizing of all string elements in `texts` 
//   and return them as a sizing `boundary`, a `[x-width, y-depth, h-height]` dimension. `attachable_text3d_boundary()` optionally 
//   takes arguments for sizing, height, line spacing, and padding to inform the dimension returned. 
//   .
//   `font` must be a font-name and style listed in `AT3D_ATTACHABLE_FONTS`.
// 
// Arguments:
//   texts = A list of one or more text strings, or one single text string. No default. 
//   ---
//   font = The name and style of the font to use. Default: `Liberation Sans`
//   size = The font size to produce text at. Default: `10`
//   h = The height (thickness) of the text produced. Default: `1`
//   line_spacing = Sets the spacing between individual lines of text; this is similar (but not identical) to leading. Default: `0.5`
//   pad = Padding applied to the boundary anchor box surrounding the generated text. Default: `0`
//   spacing = The relative spacing multiplier between characters. Default: `1`
//
// Example:
//   boundary = attachable_text3d_boundary("Ipsum");
//   // boundary == [36.2821, 9.56907, 1]
//
function attachable_text3d_boundary(texts, font=AT3D_DEFAULT_FONT, size=AT3D_DEFAULT_SIZE, h=AT3D_DEFAULT_HEIGHT, line_spacing=AT3D_DEFAULT_LINE_SPACING, pad=AT3D_DEFAULT_PAD, spacing=AT3D_DEFAULT_SPACING) = 
    assert(is_string(texts) || is_list(texts))
    assert(in_list(font, AT3D_ATTACHABLE_FONTS))
    assert(size > 0)
    assert(h > 0)
    assert(line_spacing >= 0)
    assert(pad >= 0)
    let(
        texts_ = (is_list(texts)) ? texts : [texts],
        boundaries = [for (i=texts_) attachable_text3d_singleline_boundary(i, font=font, size=size, h=h, pad=pad, spacing=spacing)],
        line_spacings = line_spacing * (len(texts_) - 1),
        msm_boundaries = _bounds_max_sum_max(boundaries)
    ) [msm_boundaries.x, sum([msm_boundaries.y, line_spacings]), msm_boundaries.z];


/// Function: attachable_text3d_singleline_boundary()
/// Usage:
///   boundary = attachable_text3d_singleline_boundary(text, font, size, h, pad);
/// Description:
///   Given text and optionally font / sizing specs, return 
///   the boundary for that text. Includes padding, 
///   font dimensions at the given size; does NOT include line_spacing.
///   Assumes oriented UP, 0 spin, center anchor. 
/// Todo: consider: should pad really not permit negative values?
///
function attachable_text3d_singleline_boundary(text, font=AT3D_DEFAULT_FONT, size=AT3D_DEFAULT_SIZE, h=AT3D_DEFAULT_HEIGHT, pad=AT3D_DEFAULT_PAD, spacing=AT3D_DEFAULT_SPACING) = 
    assert(is_string(text))
    assert(in_list(font, AT3D_ATTACHABLE_FONTS))
    assert(size > 0)
    assert(h > 0)
    assert(pad >= 0)
    let(
        m = measureTextBounds(text, size=size, font=font, spacing=spacing, halign="left")
    ) [ 
        m[1][0] + m[0][0] + pad, // the width of the text, the width of the model, along the x-axis
        m[1][1] + m[0][1] + pad, // the height of the text, the depth of the model, along the y-axis
        h + pad // the thickness of the text, the height of the model, along the z-axis
        ];


/// Function: attachable_text3d_anchors_from_boundary()
/// Usage:
///   anchors = attachable_text3d_anchors_from_boundary(bounds);
/// Description: 
///   Return consistent named anchoring based on boundary data. 
///
function attachable_text3d_anchors_from_boundary(bounds) = [
    named_anchor("text-left-back",   [-1 * (bounds.x / 2), bounds.y / 2, 0],            BACK, 180),
    named_anchor("text-left-fwd",    [-1 * (bounds.x / 2), -1 * (bounds.y / 2), 0],     FWD,  0),
    named_anchor("text-center-back", [0, bounds.y / 2, 0],                              BACK, 180),
    named_anchor("text-center-fwd",  [0, -1 * (bounds.y / 2), 0],                       FWD,  0),
    named_anchor("text-right-back",  [bounds.x / 2, bounds.y / 2, 0],                   BACK, 180),
    named_anchor("text-right-fwd",   [bounds.x / 2, -1 * (bounds.y / 2), 0],            FWD,  0)
    ];


/// Function: _bounds_max_sum_max()
/// Usage:
///   dims = _bounds_max_sum_max(bounds);
/// Description:
///   Given a list of bounding dimensions `bounds`, 
///   calculate the maximum of all `x` dimensions, them 
///   sum of all `y` dimensions, and the maximum of 
///   all `z` dimensions. The three boundary dimensions 
///   are returned as single list `dims`. 
/// Arguments:
///   bounds = a list of dimension lists
///
function _bounds_max_sum_max(bounds) = 
    assert(is_list(bounds))
    let(
        xmax = max([for (i=bounds) i.x]),
        ysum = sum([for (i=bounds) i.y]),
        zmax = max([for (i=bounds) i.z])
    ) [xmax, ysum, zmax];
 

/// Function: _fontmetricsdata_list_fonts()
/// Usage:
///   list = _fontmetricsdata_list_fonts();
///   list = _fontmetricsdata_list_fonts(<f=FONTLIST>);
/// Description:
///   Returns a list `list` of font names and styles that are present in the `fontmetricsdata.scad` listing. 
///   Only fonts with sizing data that can be used within `attachable_text3d.scad` are returned. 
///   Fonts are returned in no particular order. 
/// Arguments:
///   f = Supply an alternate font list. Default: `FONTS` (provided in `fontmetricsdata.scad`)
/// 
function _fontmetricsdata_list_fonts(font_list=FONTS) = let(
    style_remapping = [undef, "Bold", "Italic", "Bold Italic"],
    valid_fonts = [
        for (i=idx(font_list))
            (len(font_list[i][5]) > 0)
                ? str(font_list[i][0][0],
                    (font_list[i][0][1] > 0) 
                        ? str(":style=", style_remapping[ font_list[i][0][1] ]) 
                        : "" )
                : undef
        ]
    )
    list_remove_values(valid_fonts, [undef], all=true);



// Section: Constants
//
// Constant: AT3D_DEFAULT_FONT
// Description: 
//   Default font for `attachable_text3d` modules and functions when no font is specified. 
//   Currently: `Liberation Sans`
//
AT3D_DEFAULT_FONT = "Liberation Sans";

// Constant: AT3D_DEFAULT_SIZE
// Description:
//   Default size for `attachable_text3d` modules and functions when no size is specified. 
//   Currently: `10`
//
AT3D_DEFAULT_SIZE = 10;

// Constant: AT3D_DEFAULT_HEIGHT
// Description:
//   Default height for `attachable_text3d` modules and functions when no height is specified. 
//   Height is the thickness of the generated model, into the z-axis.
//   Currently: `1`
//
AT3D_DEFAULT_HEIGHT = 1;

// Constant: AT3D_DEFAULT_PAD
// Description:
//   Default padding for `attachable_text3d` modules and functions when no padding is specified. 
//   Padding is extra spacing that surrounds the entirety of a text block.
//   Currently: `0`
//
AT3D_DEFAULT_PAD = 0;

// Constant: AT3D_DEFAULT_LINE_SPACING
// Description:
//   Default line spacing for `attachable_text3d` modules and functions when no line spacing is specified. 
//   Leading *(in this library)* is the spacing between multiple lines of 
//   text within the same block. It is a constant value, and not subject to 
//   change based on the specified font size, or the measured dimensions of the 
//   font face. 
//   *This is similar, though not identical, to typographical leading.*
//   Currently: `0.5`
//
AT3D_DEFAULT_LINE_SPACING = 0.5;

// Constant: AT3D_DEFAULT_ALIGNMENT
// Description:
//   Default horizontal alignment for `attachable_text3d` modules when no alignment is specified. 
//   Currently: `LEFT`
//
AT3D_DEFAULT_ALIGNMENT = LEFT;

// Constant: AT3D_DEFAULT_SPACING
// Description:
//   Default spacing for `attachable_text3d` modules and functions when no spacing is specified.
//   *This default is pulled from the built-in`text()`, BOSL2's `text3d()`, and from `fontmetric.scad`'s `measureTextBounds()`.* 
//   Currently: `1`
//
AT3D_DEFAULT_SPACING = 1;

// Constant: AT3D_DEFAULT_DIRECTION
// Description:
//   Default direction for `attachable_text3d` modules and functions when no direction is specified.
//   *This default is pulled from the built-in`text()` and BOSL2's `text3d()`.* 
//   Currently: `ltr`
//
AT3D_DEFAULT_DIRECTION = "ltr";

// Constant: AT3D_DEFAULT_LANGUAGE
// Description:
//   Default language for `attachable_text3d` modules and functions when no language is specified.
//   *This default is pulled from the built-in`text()` and BOSL2's `text3d()`.* 
//   Currently: `en`
//
AT3D_DEFAULT_LANGUAGE = "en";

// Constant: AT3D_DEFAULT_SCRIPT
// Description:
//   Default script for `attachable_text3d` modules and functions when no script is specified.
//   *This default is pulled from the built-in`text()` and BOSL2's `text3d()`.* 
//   Currently: `latin`
//
AT3D_DEFAULT_SCRIPT = "latin";

// Constant: AT3D_DEFAULT_ANCHOR
// Description:
//   Default anchor for `attachable_text3d` modules and functions when no anchor is specified. 
//   Currently: `CENTER`
//
AT3D_DEFAULT_ANCHOR = CENTER;

// Constant: AT3D_DEFAULT_SPIN
// Description:
//   Default spin for `attachable_text3d` modules and functions when no spin is specified. 
//   Currently: `0`
//
AT3D_DEFAULT_SPIN = 0;

// Constant: AT3D_DEFAULT_ORIENT
// Description:
//   Default orientation for `attachable_text3d` modules and functions when no orient is specified. 
//   Currently: `UP`
//
AT3D_DEFAULT_ORIENT = UP;

// Constant: AT3D_ATTACHABLE_FONTS
// Description:
//   A sorted list of all known fonts within `fontmetricsdata.scad` that have 
//   sufficient measurement information so as to use them in attachable modules.  
//   *This list is dynamically generated at runtime.*
//
AT3D_ATTACHABLE_FONTS = sort(_fontmetricsdata_list_fonts());



