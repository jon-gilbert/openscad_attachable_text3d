# openscad_attachable_text3d
OpenSCAD module for creating blocks of 3D text that are attachable with BOSL2.

The `attachable_text3d.scad` library marries BOSL2 bi-directional attachability and `fontmetrics.scad`-measured text dimensions into a set of modules that produce attachable 3D text: that is, modeled 3D objects that can use BOSL2's attachments functionality to join text to other text, arbitrary shapes, or existing attachment-aware models, by using pre-measured font dimensions as sizing data. 

OpenSCAD provides a rudimentary [`text()` built-in function](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Text), but only for 2D models. [BOSL2](https://www.github.com/revarbat/BOSL2/) takes that a step further, and provides a [`text3d()` module](https://github.com/revarbat/BOSL2/wiki/shapes3d.scad#module-text3d), and those models may be attached to other BOSL2 attachable primatives. This attachability limitation is because post hoc dimension information of models within OpenSCAD is not available, and BOSL2 leverages the built-in `text()` to create `text3d()` models. The [fontmetrics](https://www.thingiverse.com/thing:3004457) library has fairly accurate per-character dimensions for a variety of font faces and styles. `attachable_text3d()` uses `fontmetrics` to measure the text to build, then builds it with BOSL2, and returns a fully [attachable](https://github.com/reverbat/BOSL2/wiki/attachments.scad) model. 


# Installation

## Required OpenSCAD Version

Using the `openscad_attachable_text3d` library requires OpenSCAD 2021.01 or later. Visit https://openscad.org/ for installation instructions.

## Requried External Libraries

### BOSL2

Belfry OpenSCAD Library (v.2). Authored by a number of contributors. Located at https://github.com/revarbat/BOSL2

To download this library, follow the instructions provided at https://github.com/revarbat/BOSL2#installation

### fontmetrics

Fontmetrics - Measuring and wrapping text in OpenSCAD. Authored by Alexander Pruss. Located at https://www.thingiverse.com/thing:3004457

To use this library and its datafile, download both `fontmetrics.scad` and `fontmetricsdata.scad` from https://www.thingiverse.com/thing:3004457/files into your OpenSCAD library directory.

# Quick Start

### A basic attachable block of text:
```
attachable_text3d("Hello");
```

### That same attachable block of text, with its anchors exposed:
```
attachable_text3d("Hello") 
    show_anchors();
```

### Attached blocks of text:
```
attachable_text3d("Block 1")
    attach(RIGHT, LEFT)
        attachable_text3d(", and of couse, ")
            attach(RIGHT, LEFT)
                attachable_text3d("Block 2");
```

Additional examples are available in [this repository's wiki](https://github.com/jon-gilbert/openscad_attachable_text3d/wiki).

# Author & License

This library is copyright 2023 Jonathan Gilbert <jong@jong.org>, and released for use under the [MIT License](LICENSE.md).

