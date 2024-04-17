# openscad_attachable_text3d

OpenSCAD module for creating blocks of 3D text that are attachable with BOSL2.

The `openscad_attachable_text3d` library marries BOSL2 bi-directional attachability 
and `fontmetrics.scad`-measured text dimensions into a set of modules that produce 
attachable 3D text: that is, modeled 3D objects that can use BOSL2's attachments 
functionality to join text to other text, arbitrary shapes, or existing 
attachment-aware models, by using pre-measured font dimensions as sizing data. 

OpenSCAD provides a rudimentary [`text()` built-in function](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Text), 
but only for 2D models. [BOSL2](https://www.github.com/revarbat/BOSL2/) takes 
that a step further, and provides a [`text3d()` module](https://github.com/revarbat/BOSL2/wiki/shapes3d.scad#module-text3d), 
and those models may be attached to other BOSL2 attachable primatives. This 
attachability limitation is because post hoc dimension information of models 
within OpenSCAD is not available, and BOSL2 leverages the built-in `text()` 
to create `text3d()` models. The [fontmetrics](https://www.thingiverse.com/thing:3004457) 
library has fairly accurate per-character dimensions for a variety of font 
faces and styles. 

`attachable_text3d()` uses `fontmetrics` to measure the text to build, then builds 
it with BOSL2, and returns a fully [attachable](https://github.com/reverbat/BOSL2/wiki/attachments.scad) 
model. 


## Use & Examples

[This project's wiki](https://github.com/jon-gilbert/openscad_attachable_text3d/wiki) has examples and details on implementation, 
as well as [inline reference SCAD documentation](https://github.com/jon-gilbert/openscad_attachable_text3d/wiki/attachable_text3d.scad).

```
include <attachable_text3d.scad>

attachable_text3d("Hello") 
    show_anchors();
```
![hello-anchored](https://user-images.githubusercontent.com/19860563/235554305-f08ea39a-265d-45cb-8ffc-3930eb450c4b.png)


# Installation

1. Download the most recent release of `openscad_attachable_text3d` from https://github.com/jon-gilbert/openscad_attachable_text3d/releases/latest 
2. Unpack the zipfile or tarball. Inside will be a directory, named `openscad_attachable_text3d-0.8` (where `0.8` is the version of the release). Extract that folder to your OpenSCAD library directory
3. Rename that release directory from `openscad_attachable_text3d-0.8` to just `openscad_attachable_text3d`

Details on installation of this library [can be found here](https://github.com/jon-gilbert/openscad_attachable_text3d/wiki/Installation), 
including notes on dependencies.

## Required Libraries
You'll need the BOSL2 framework to get this working; see https://github.com/BelfrySCAD/BOSL2/ for instructions on how to download and incorporate it. 

## fontmetrics & fontmetricsdata

The `fontmetrics` and `fontmetricsdata` SCAD libraries are by [Alexander Pruss](https://www.thingiverse.com/arpruss), licensed under [CC-BY-4.0](https://creativecommons.org/licenses/by/4.0/). They're redistributed within `openscad_attachable_text3d`, here.

### fontmetrics changes

The fontmetrics.scad library this project depends on has a minor bug in its library. It's easily rectified, as detailed below:

At line 27 of the `fontmetrics.scad` library, a function `_isString()` is defined that compares `v` with 
an empty string, `""`. This breaks under certain circumstances.  A more thorough, safer implementation 
is to use OpenSCAD's built-in `is_string()` function (available as of their 2019.05 release). You can make 
that change directly into `fontmetrics.scad` as such:

```
27c27
< function _isString(v) = v >= "";
---
> function _isString(v) = is_string(v);
```

This release of `openscad_attachable_text3d` has the `_isString()` fix applied.

# Author & License

This library is copyright 2023 Jonathan Gilbert <jong@jong.org>, and released for use under the [MIT License](LICENSE.md).

