// LibFile: attachable_text3d.scad 
//   OpenSCAD module for creating blocks of 3D text that are attachable with BOSL2. 
//
// Includes:
//   include <openscad_attachable_text3d/attachable_text3d.scad>
// Continues:
//    You must additionally have the `fontmetrics.scad` and `fontmetricsdata.scad`
//    libraries by Alexander Pruss installed. Source these from
//    https://www.thingiverse.com/thing:3004457. 
//    These libraries are available under a CC-BY-4.0 license. 
//


include <BOSL2/std.scad>

/// fontmetricsdata.scad is included, as well as use-ing 
/// fontmetrics.scad to get direct access to its 
/// FONTS list; we use that within _fontmetricsdata_list_fonts().
include <fontmetricsdata.scad>
use <fontmetrics.scad>



// Section: Attachable Text Modules
//
// Module: attachable_text3d()
// Synopsis: Creates an attachable 3D model of text
// Usage:
//   attachable_text3d(text);
//   attachable_text3d(text, <font="Liberation Sans">, <size=10>, <h=1>, <pad=0>, <align=LEFT>, <spacing=1>, <direction="ltr">, <language="en">, <script="latin">, <anchor=CENTER>, <spin=0>, <orient=UP>);
//
// Description:
//   Given a string of text `text`, or a list of strings (also `text`), create a single 3D model of that text. The resulting model will have BOSL2 attachable anchor points on it, and can be positioned and attached to as needed. 
//   .
//   `font` must be a font-name and style listed in `AT3D_ATTACHABLE_FONTS`,  because those are the fonts for which accurate measurements are available. Font families, or families and styles, may be specified; examples: `font="Times New Roman"`, `font="Liberation Serif:style=Italic"`, `font="Arial:style=Bold Italic"`. When not specified, `font` defaults to whatever `AT3D_DEFAULT_FONT` is set. 
//   .
//   All text is by default aligned to the left. Horizontal alignment can be adjusted by setting `align` to one of `LEFT`, `CENTER`, or `RIGHT`. 
//   .
//   The anchor bounding box constructed for the text is as wide as the longest single text element; and, as deep as the sum of text heights of each text element; and, the height of `h` used. The bounding box for all strings represented within `text` can be exposed by setting `debug_bounding` to `true`.
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
                            ? attachable_text3d_boundary(select(texts_, 0, i - 1),
                                font=font,
                                size=size,
                                h=h,
                                line_spacing=line_spacing,
                                pad=pad,
                                spacing=spacing)
                            : [0, 0, 0]
                        )
                    fwd(prevbounds.y)
                        _attachable_text3d_one_line(texts_[i],
                            font=font,
                            size=size,
                            h=h,
                            pad=pad,
                            spacing=spacing,
                            direction=direction,
                            language=language,
                            script=script,
                            anchor=align);

            if (debug_bounding)
                translate([-1 * (boundary.x/2), -1 * (boundary.y/2), -1 * (boundary.z/2)])
                    _bounds_debugging(boundary);
        }
        children();
    }
}


// Module: attachable_text3d_multisize()
// Synopsis: Creates an attachable 3D model of text with multiple sizes
// Usage:
//   attachable_text3d_multisize(text_and_sizes);
//   attachable_text3d_multisize(text_and_sizes, <font="Liberation Sans">, <h=1>, <pad=0>, <align=LEFT>, <spacing=1>, <direction="ltr">, <language="en">, <script="latin">, <anchor=CENTER>, <spin=0>, <orient=UP>);
//
// Description:
//   Given a list of text and sizing pairings `text_and_sizes`, create a single 3D model of that text. Each `[text, size]` pairing within `text_and_sizes` will be shown in the specified `size`, aligned as specified by `align`. `text` may be a list with multiple elements, all of which will have that pairing's `size` applied. The resulting model will have BOSL2 attachable anchor points on it, and can be positioned and attached to as needed. 
//   .
//   `font` must be a font-name and style listed in `AT3D_ATTACHABLE_FONTS`,  because those are the fonts for which accurate measurements are available. Font families, or families and styles, may be specified; examples: `font="Times New Roman"`, `font="Liberation Serif:style=Italic"`, `font="Arial:style=Bold Italic"`. When not specified, `font` defaults to whatever `AT3D_DEFAULT_FONT` is set. 
//   .
//   All text is by default aligned to the left. Horizontal alignment can be adjusted by setting `align` to one of `LEFT`, `CENTER`, or `RIGHT`. 
//   .
//   The anchor bounding box constructed for the text is as wide as the longest single text element; and, as deep as the sum of text heights of each text element; and, the height of `h` used. The bounding box for all strings represented within `text` can be exposed by setting `debug_bounding` to `true`.
//
// Arguments:
//   text_and_sizes = A list of one or more `[text, size]` pairings to produce a model of. No default.
//   ---
//   font = The name and style of the font to use. Default: `Liberation Sans`
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
// Named Anchors: In addition to the cardinal anchor points provided by BOSL2, `attachable_text3d_multisize()` vends the following six additional named anchors:
//   text-left-back = The back-left most corner, oriented backwards
//   text-left-fwd = The forward-left most corner, oriented forwards
//   text-center-back = The back-center face, oriented backwards
//   text-center-fwd = The forward-center face, oriented forwards
//   text-right-back = The top-right most corner, oriented backwards
//   text-right-fwd = The forward-right most corner, oriented forwards
// Figure: Available named anchors:
//   v = [[["Lorem"], 10]];
//   expose_anchors() attachable_text3d_multisize(v) show_anchors(std=false);
//
// Example: A single line of attachable text:
//   attachable_text3d_multisize([[["Lorem Ipsum"], 10]]);
//
// Example: Multiple lines of text at various sizes:
//   v = [
//      [["Lorem ipsum dolor sit amet,", 
//        "consectetur adipiscing elit,", 
//        "sed do eiusmod tempor incididunt ut", 
//        "labore et dolore magna aliqua."], 10],
//      [["Ut enim ad minim veniam,", 
//        "quis nostrud exercitation ullamco laboris", 
//        "nisi ut aliquip ex ea commodo consequat."], 5],
//     ];
//   attachable_text3d_multisize(v);
//
// Todo:
//   assert the geometry of texts_and_sizes; and make sure all [0] are texts or lists and all [1] are numbers
//
module attachable_text3d_multisize(texts_and_sizes, font=AT3D_DEFAULT_FONT, h=AT3D_DEFAULT_HEIGHT, line_spacing=AT3D_DEFAULT_LINE_SPACING, pad=AT3D_DEFAULT_PAD, align=LEFT, spacing=AT3D_DEFAULT_SPACING, direction=AT3D_DEFAULT_DIRECTION, language=AT3D_DEFAULT_LANGUAGE, script=AT3D_DEFAULT_SCRIPT, debug_bounding=false, anchor=AT3D_DEFAULT_ANCHOR, spin=AT3D_DEFAULT_SPIN, orient=AT3D_DEFAULT_ORIENT) {    
    // TRodo - need a list geometry checker, and need to make sure all [0] are text or lists and all [1] are sizes
    assert(in_list(font, AT3D_ATTACHABLE_FONTS));
    assert(h > 0);
    assert(line_spacing >= 0);
    assert(pad >= 0);
    assert(in_list(align, [LEFT, CENTER, RIGHT]));
 
    b = attachable_text3d_multisize_boundary(texts_and_sizes, font=font, h=h, line_spacing=line_spacing, pad=pad, spacing=spacing);
    boundary = b[0];
    section_boundaries = b[1];

    first_line = (is_list(texts_and_sizes[0][0])) ? texts_and_sizes[0][0][0] : texts_and_sizes[0][0];
    firstline_boundary = attachable_text3d_boundary(first_line, font=font, size=texts_and_sizes[0][1], h=h, pad=pad, spacing=spacing);

    anchors = attachable_text3d_anchors_from_boundary(boundary);

    attachable(anchor, spin, orient, size=boundary, anchors=anchors) {
        union() {
            back(firstline_boundary.y/2)
            translate([
                    (in_list(align, [LEFT, CENTER]))
                        ? -1 * (boundary.x * ((align == LEFT) ? 0.5 : 0))
                        :  1 * (boundary.x * 0.5),
                    0 - (firstline_boundary.y / 2) + (boundary.y / 2),
                    0])
                for (i=idx(texts_and_sizes))
                    let(
                        move_fwd = (i > 0)
                            ? sum([ sum([for (j=select(section_boundaries, 0, i-1)) j.y ]), line_spacing * i ])
                            : 0
                        )
                    fwd(move_fwd)
                        attachable_text3d(texts_and_sizes[i][0], size=texts_and_sizes[i][1], 
                                font=font, h=h, line_spacing=line_spacing, pad=pad, 
                                align=align, spacing=spacing, direction=direction, language=language, 
                                script=script, anchor="text-left-back");

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
///   Given a single line of text `text`, and optionally font / sizing specs, create a 3d model for that text. Includes padding, font dimensions at the given size. Does NOT include line spacing. model is attachable with extra anchors.
///
module _attachable_text3d_one_line(text, font=AT3D_DEFAULT_FONT, size=AT3D_DEFAULT_SIZE, h=AT3D_DEFAULT_HEIGHT, pad=AT3D_DEFAULT_PAD, spacing=AT3D_DEFAULT_SPACING, direction=AT3D_DEFAULT_DIRECTION, language=AT3D_DEFAULT_LANGUAGE, script=AT3D_DEFAULT_SCRIPT, debug_bounding=false, anchor=LEFT, spin=AT3D_DEFAULT_SPIN, orient=AT3D_DEFAULT_ORIENT) {
    assert(is_string(text));
    assert(in_list(font, AT3D_ATTACHABLE_FONTS));
    assert(size > 0);
    assert(h > 0);
    assert(pad >= 0);

    boundary = attachable_text3d_boundary([text], font=font, size=size, h=h, pad=pad, spacing=spacing);
    anchors = attachable_text3d_anchors_from_boundary(boundary);

    attachable(anchor, spin, orient, size=boundary, anchors=anchors) {
        translate( [-1 * (boundary.x/2), -1 * (boundary.y / 2), 0 ] )
            union() {
                text3d(text,
                    font=font,
                    size=size,
                    h=h,
                    spacing=spacing,
                    direction=direction,
                    language=language,
                    script=script);

                if (debug_bounding)
                     _bounds_debugging(boundary);
            }
        children();
    }
}


/// Module: _bounds_debugging()
/// Description:
///   Given a set of rectangular boundary coordinates as a list `bounds`, create a magenta-colored translucent wireframe that shows where those bounds are. 
///
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
// Function: attachable_text3d_boundary()
// Synopsis: Returns a size listing of a given block of attachable text
// Usage:
//   boundary = attachable_text3d_boundary(text);
//   boundary = attachable_text3d_boundary(texts);
//   boundary = attachable_text3d_boundary(texts, <font="Liberation Sans">, <size=10>, <h=1>, <line_spacing=0.5>, <pad=0>);
//
// Description:
//   Given a list of strings `texts`, calculate the boundary sizing of all string elements in `texts` and return them as a sizing `boundary`, a `[x-width, y-depth, h-height]` dimension. `attachable_text3d_boundary()` optionally takes arguments for sizing, height, line spacing, and padding to inform the dimension returned. 
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


// Function: attachable_text3d_multisize_boundary()
// Synopsis: Returns a size listing of a given block of attachable multi-sized text
// Usage:
//   boundary_and_bounds = attachable_text3d_multisize_boundary(text_and_sizes);
//   boundary_and_bounds = attachable_text3d_multisize_boundary(text_and_sizes, <font="Liberation Sans">, <h=1>, <line_spacing=0.5>, <pad=0>);
//
// Description:
//   Given a list of text and sizing pairings `text_and_sizes`, calculate the dimensional sizing of those pairs and return it as a list containing both sizing `boundary` (a `[x-width, y-depth, z-height]` dimension list), and the individual boundary elements of each entry found in `text_and_sizes`. Each `[text, size]` pairing within `text_and_sizes` will have its boundary calculated similar to `attachable_text3d_boundary()`, and the returned `boundary` will have them incorporated with any `line_spacing` inbetween each pairing as needed. `attachable_text3d_multisize_boundary()` optionally takes arguments for height, line spacing, and padding to inform the dimension returned. 
//   .
//   `font` must be a font-name and style listed in `AT3D_ATTACHABLE_FONTS`.
// 
// Arguments:
//   text_and_sizes = A list of one or more `[text, size]` pairings to produce a model of. No default.
//   ---
//   font = The name and style of the font to use. Default: `Liberation Sans`
//   h = The height (thickness) of the text produced. Default: `1`
//   line_spacing = Sets the spacing between individual lines of text, and between pairings; this is similar (but not identical) to leading. Default: `0.5`
//   pad = Padding applied to the boundary anchor box surrounding the generated text. Default: `0`
//   spacing = The relative spacing multiplier between characters. Default: `1`
//
// Example: a multisize boundary call. Note that each individual block has its own dimension available:
//   v = [
//     [["Lorem Ipsum"], 10],
//     [["dolor sit amet", "consectetur adipiscing elit"], 5]
//     ];
//   b = attachable_text3d_multisize(v);
//   // b == [
//   //   [78.494, 20.6475, 1],     // full boundary
//   //   [
//   //      [78.494, 9.56907, 1],  // first block
//   //      [77.6468, 10.5784, 1]  // second block
//   //     ]
//   //   ]
//
// Todo:
//   assert the geometry of texts_and_sizes; and make sure all [0] are texts or lists and all [1] are numbers
//
function attachable_text3d_multisize_boundary(texts_and_sizes, font=AT3D_DEFAULT_FONT, h=AT3D_DEFAULT_HEIGHT, line_spacing=AT3D_DEFAULT_LINE_SPACING, pad=AT3D_DEFAULT_PAD, spacing=AT3D_DEFAULT_SPACING) = 
    // TRodo - need a list geometry checker, and need to make sure all [0] are text or lists and all [1] are sizes
    assert(in_list(font, AT3D_ATTACHABLE_FONTS))
    assert(h > 0)
    assert(line_spacing >= 0)
    assert(pad >= 0)
    let(
        boundaries = [for (i=idx(texts_and_sizes)) 
            attachable_text3d_boundary(texts_and_sizes[i][0], size=texts_and_sizes[i][1], 
                    font=font, h=h, line_spacing=line_spacing, pad=pad, spacing=spacing) ],
        line_spacings = line_spacing * (len(texts_and_sizes) - 1),
        msm_boundaries = _bounds_max_sum_max(boundaries)
    ) [ [msm_boundaries.x, sum([msm_boundaries.y, line_spacings]), msm_boundaries.z], boundaries];


/// Function: attachable_text3d_singleline_boundary()
/// Usage:
///   boundary = attachable_text3d_singleline_boundary(text, font, size, h, pad);
/// Description:
///   Given text and optionally font / sizing specs, return the boundary for that text. Includes padding, font dimensions at the given size; does NOT include line_spacing. Assumes oriented UP, 0 spin, center anchor. 
///
/// Todo: 
///   consider: should pad really not permit negative values?
///   consdier: really, really should reconsider handling `undef` for `text`. Maybe something like, "treat_undef_as_empty" or "ignore_undef"? and frankly, what happens when `text` is an int? or a list? cmon, folks.
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
///   Given a list of bounding dimensions `bounds`, calculate the maximum of all `x` dimensions, them sum of all `y` dimensions, and the maximum of all `z` dimensions. The three boundary dimensions are returned as single list `dims`. 
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
///   Returns a list `list` of font names and styles that are present in the `fontmetricsdata.scad` listing. Only fonts with sizing data that can be used within `attachable_text3d.scad` are returned. Fonts are returned in no particular order. 
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
// Synopsis: Default font name: Liberation Sans
// Description: 
//   Default font for `attachable_text3d` modules and functions when no font is specified. 
//   Currently: `Liberation Sans`
//
AT3D_DEFAULT_FONT = "Liberation Sans";

// Constant: AT3D_DEFAULT_SIZE
// Synopsis: Default font size: 10
// Description:
//   Default size for `attachable_text3d` modules and functions when no size is specified. 
//   Currently: `10`
//
AT3D_DEFAULT_SIZE = 10;

// Constant: AT3D_DEFAULT_HEIGHT
// Synopsis: Default font height: 1
// Description:
//   Default height for `attachable_text3d` modules and functions when no height is specified. Height is the thickness of the generated model, into the z-axis.
//   Currently: `1`
//
AT3D_DEFAULT_HEIGHT = 1;

// Constant: AT3D_DEFAULT_PAD
// Synopsis: Default padding to surround attachable text: 0
// Description:
//   Default padding for `attachable_text3d` modules and functions when no padding is specified. Padding is extra spacing that surrounds the entirety of a text block.
//   Currently: `0`
//
AT3D_DEFAULT_PAD = 0;

// Constant: AT3D_DEFAULT_LINE_SPACING
// Synopsis: Default spacing between lines: 0.5
// Description:
//   Default line spacing for `attachable_text3d` modules and functions when no line spacing is specified. Leading *(in this library)* is the spacing between multiple lines of text within the same block. It is a constant value, and not subject to change based on the specified font size, or the measured dimensions of the font face. 
//   *This is similar, though not identical, to typographical leading.*
//   Currently: `0.5`
//
AT3D_DEFAULT_LINE_SPACING = 0.5;

// Constant: AT3D_DEFAULT_ALIGNMENT
// Synopsis: Default alignment: LEFT
// Description:
//   Default horizontal alignment for `attachable_text3d` modules when no alignment is specified. 
//   Currently: `LEFT`
//
AT3D_DEFAULT_ALIGNMENT = LEFT;

// Constant: AT3D_DEFAULT_SPACING
// Synopsis: Default spacing: 1
// Description:
//   Default spacing for `attachable_text3d` modules and functions when no spacing is specified.
//   *This default is pulled from the built-in`text()`, BOSL2's `text3d()`, and from `fontmetric.scad`'s `measureTextBounds()`.* 
//   Currently: `1`
//
AT3D_DEFAULT_SPACING = 1;

// Constant: AT3D_DEFAULT_DIRECTION
// Synopsis: Default text direction: ltr (left-to-right)
// Description:
//   Default direction for `attachable_text3d` modules and functions when no direction is specified.
//   *This default is pulled from the built-in`text()` and BOSL2's `text3d()`.* 
//   Currently: `ltr`
//
AT3D_DEFAULT_DIRECTION = "ltr";

// Constant: AT3D_DEFAULT_LANGUAGE
// Synopsis: Default text language: en
// Description:
//   Default language for `attachable_text3d` modules and functions when no language is specified.
//   *This default is pulled from the built-in`text()` and BOSL2's `text3d()`.* 
//   Currently: `en`
//
AT3D_DEFAULT_LANGUAGE = "en";

// Constant: AT3D_DEFAULT_SCRIPT
// Synopsis: Default text script: latin
// Description:
//   Default script for `attachable_text3d` modules and functions when no script is specified.
//   *This default is pulled from the built-in`text()` and BOSL2's `text3d()`.* 
//   Currently: `latin`
//
AT3D_DEFAULT_SCRIPT = "latin";

// Constant: AT3D_DEFAULT_ANCHOR
// Synopsis: Default attachable positioning anchor: CENTER
// Description:
//   Default anchor for `attachable_text3d` modules and functions when no anchor is specified. 
//   Currently: `CENTER`
//
AT3D_DEFAULT_ANCHOR = CENTER;

// Constant: AT3D_DEFAULT_SPIN
// Synopsis: Default attachable spin, in degrees: 0
// Description:
// Description:
//   Default spin for `attachable_text3d` modules and functions when no spin is specified. 
//   Currently: `0`
//
AT3D_DEFAULT_SPIN = 0;

// Constant: AT3D_DEFAULT_ORIENT
// Synopsis: Default attachable orientation: UP
// Description:
//   Default orientation for `attachable_text3d` modules and functions when no orient is specified. 
//   Currently: `UP`
//
AT3D_DEFAULT_ORIENT = UP;

// Constant: AT3D_ATTACHABLE_FONTS
// Synopsis: Sorted list of known fonts
// Description:
//   A sorted list of all known fonts within `fontmetricsdata.scad` that have sufficient measurement information so as to use them in attachable modules.  
//   *This list is dynamically generated at runtime.*
//
AT3D_ATTACHABLE_FONTS = sort(_fontmetricsdata_list_fonts());



