# openscad_attachable_text3d

OpenSCAD module for creating blocks of 3D text that are attachable with BOSL2.

The `attachable_text3d.scad` library marries BOSL2 bi-directional attachability 
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

```
include <attachable_text3d.scad>

attachable_text3d("Hello") 
    show_anchors();
```
![hello-anchored](https://user-images.githubusercontent.com/19860563/235554305-f08ea39a-265d-45cb-8ffc-3930eb450c4b.png)

# Installation

Details on installation of this library [can be found here](https://github.com/jon-gilbert/openscad_attachable_text3d/wiki/Installation), including notes on dependencies.

# Use & Examples

[This project's wiki](https://github.com/jon-gilbert/openscad_attachable_text3d/wiki) has examples and details on implementation, 
as well as [inline reference SCAD documentation](https://github.com/jon-gilbert/openscad_attachable_text3d/wiki/attachable_text3d.scad).

# Author & License

This library is copyright 2023 Jonathan Gilbert <jong@jong.org>, and released for use under the [MIT License](LICENSE.md).

