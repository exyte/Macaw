## W3C SVG Test Suite Coverage

There are 521 SVG tests in total. 215 files use features that are not covered by Macaw right now, namely:
* [Scripts](https://www.w3.org/TR/SVG11/script.html#ScriptElement) (59)
* [Interactivity](https://www.w3.org/TR/SVG11/interact.html) (33)
* [Linking](https://www.w3.org/TR/SVG11/linking.html) (16)
* [Glyphs](https://www.w3.org/TR/SVG11/text.html#AltGlyphElement) (4)
* [Styling](https://www.w3.org/TR/SVG11/styling.html#StyleElement) (25)
* [Animation](https://www.w3.org/TR/SVG11/animate.html#AnimateElement) (71)
* [switch/object](https://www.w3.org/TR/SVG11/backward.html) (7)

The rest 306 tests can be split into following categories:
* 30.7% passed (94)
* 14.1% filters (43) [#390](https://github.com/exyte/Macaw/issues/390)
* 7.8% images (24) [wpt issue](https://github.com/web-platform-tests/wpt/issues/11178) 
* 2.6% markers (8) [#392](https://github.com/exyte/Macaw/issues/392)
* 19.9% text (61) [#391](https://github.com/exyte/Macaw/issues/391) 
* 25.2% blocked by issues (77)

Status of each test:

|Name  |Status |
|------|-------|
|[color-prof-01-f-manual](w3cSVGTests/color-prof-01-f-manual.svg)       | [wpt issue](https://github.com/web-platform-tests/wpt/issues/11178)                                          |
|[color-prop-01-b-manual](w3cSVGTests/color-prop-01-b-manual.svg)       | ✅                                                |
|[color-prop-02-f-manual](w3cSVGTests/color-prop-02-f-manual.svg)       | ✅                                                |
|[color-prop-03-t-manual](w3cSVGTests/color-prop-03-t-manual.svg)       | ✅                                                |
|[color-prop-04-t-manual](w3cSVGTests/color-prop-04-t-manual.svg)       | [#387](https://github.com/exyte/Macaw/issues/387)                                                 |
|[color-prop-05-t-manual](w3cSVGTests/color-prop-05-t-manual.svg)       | [#388](https://github.com/exyte/Macaw/issues/388)                                             |
|[conform-viewers-02-f-manual](w3cSVGTests/conform-viewers-02-f-manual.svg)       | [wpt issue](https://github.com/web-platform-tests/wpt/issues/11178) |
|[conform-viewers-03-f-manual](w3cSVGTests/conform-viewers-03-f-manual.svg)       | [wpt issue](https://github.com/web-platform-tests/wpt/issues/11178)  |
|[coords-coord-01-t-manual](w3cSVGTests/coords-coord-01-t-manual.svg)       | ✅                                                 |
|[coords-coord-02-t-manual](w3cSVGTests/coords-coord-02-t-manual.svg)       | ✅                                                 |
|[coords-trans-01-b-manual](w3cSVGTests/coords-trans-01-b-manual.svg)       | ✅                                                 |
|[coords-trans-02-t-manual](w3cSVGTests/coords-trans-02-t-manual.svg)       | ✅                                                 |
|[coords-trans-03-t-manual](w3cSVGTests/coords-trans-03-t-manual.svg)       | ✅                                                 |
|[coords-trans-04-t-manual](w3cSVGTests/coords-trans-04-t-manual.svg)       | ✅                                                 |
|[coords-trans-05-t-manual](w3cSVGTests/coords-trans-05-t-manual.svg)       | ✅                                                 |
|[coords-trans-06-t-manual](w3cSVGTests/coords-trans-06-t-manual.svg)       | ✅                                                 |
|[coords-trans-07-t-manual](w3cSVGTests/coords-trans-07-t-manual.svg)       | ✅                                                 |
|[coords-trans-08-t-manual](w3cSVGTests/coords-trans-08-t-manual.svg)       | ✅                                                 |
|[coords-trans-09-t-manual](w3cSVGTests/coords-trans-09-t-manual.svg)       | ✅                                                 |
|[coords-trans-10-f-manual](w3cSVGTests/coords-trans-10-f-manual.svg)       | [#347](https://github.com/exyte/Macaw/issues/347) |
|[coords-trans-11-f-manual](w3cSVGTests/coords-trans-11-f-manual.svg)        | [#347](https://github.com/exyte/Macaw/issues/347) |
|[coords-trans-12-f-manual](w3cSVGTests/coords-trans-12-f-manual.svg)        | [#347](https://github.com/exyte/Macaw/issues/347) |
|[coords-trans-13-f-manual](w3cSVGTests/coords-trans-13-f-manual.svg)        | [#347](https://github.com/exyte/Macaw/issues/347) |
|[coords-trans-14-f-manual](w3cSVGTests/coords-trans-14-f-manual.svg)        | [#347](https://github.com/exyte/Macaw/issues/347) |
|[coords-transformattr-01-f-manual](w3cSVGTests/coords-transformattr-01-f-manual.svg)       | ✅                                                 |
|[coords-transformattr-02-f-manual](w3cSVGTests/coords-transformattr-02-f-manual.svg)       | ✅                                                 |
|[coords-transformattr-03-f-manual](w3cSVGTests/coords-transformattr-03-f-manual.svg)       | ✅                                                 |
|[coords-transformattr-04-f-manual](w3cSVGTests/coords-transformattr-04-f-manual.svg)       | ✅                                                 |
|[coords-transformattr-05-f-manual](w3cSVGTests/coords-transformattr-05-f-manual.svg)       | ✅                                                 |
|[coords-units-01-b-manual](w3cSVGTests/coords-units-01-b-manual.svg)       | [#389](https://github.com/exyte/Macaw/issues/389) |
|[coords-units-02-b-manual](w3cSVGTests/coords-units-02-b-manual.svg)       | [#389](https://github.com/exyte/Macaw/issues/389) |
|[coords-units-03-b-manual](w3cSVGTests/coords-units-03-b-manual.svg)       | [#389](https://github.com/exyte/Macaw/issues/389) |
|[coords-viewattr-01-b-manual](w3cSVGTests/coords-viewattr-01-b-manual.svg)       | [#344](https://github.com/exyte/Macaw/issues/344)   |
|[coords-viewattr-02-b-manual](w3cSVGTests/coords-viewattr-02-b-manual.svg)       | [#344](https://github.com/exyte/Macaw/issues/344) |
|[coords-viewattr-03-b-manual](w3cSVGTests/coords-viewattr-03-b-manual.svg)       | [#344](https://github.com/exyte/Macaw/issues/344) |
|[coords-viewattr-04-f-manual](w3cSVGTests/coords-viewattr-04-f-manual.svg)       | [#344](https://github.com/exyte/Macaw/issues/344) |
|[filters-background-01-f-manual](w3cSVGTests/filters-background-01-f-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390) |
|[filters-blend-01-b-manual](w3cSVGTests/filters-blend-01-b-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390) |
|[filters-color-01-b-manual](w3cSVGTests/filters-color-01-b-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390) |
|[filters-color-02-b-manual](w3cSVGTests/filters-color-02-b-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390) |
|[filters-composite-02-b-manual](w3cSVGTests/filters-composite-02-b-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390) |
|[filters-composite-03-f-manual](w3cSVGTests/filters-composite-03-f-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390) |
|[filters-composite-04-f-manual](w3cSVGTests/filters-composite-04-f-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390)        |
|[filters-composite-05-f-manual](w3cSVGTests/filters-composite-05-f-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390)         |
|[filters-comptran-01-b-manual](w3cSVGTests/filters-comptran-01-b-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390)         |
|[filters-conv-01-f-manual](w3cSVGTests/filters-conv-01-f-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390)                |
|[filters-conv-02-f-manual](w3cSVGTests/filters-conv-02-f-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390)                |
|[filters-conv-03-f-manual](w3cSVGTests/filters-conv-03-f-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390)                |
|[filters-conv-04-f-manual](w3cSVGTests/filters-conv-04-f-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390)                |
|[filters-conv-05-f-manual](w3cSVGTests/filters-conv-05-f-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390)                |
|[filters-diffuse-01-f-manual](w3cSVGTests/filters-diffuse-01-f-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390)               |
|[filters-displace-01-f-manual](w3cSVGTests/filters-displace-01-f-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390)                 |
|[filters-displace-02-f-manual](w3cSVGTests/filters-displace-02-f-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390)                 |
|[filters-example-01-b-manual](w3cSVGTests/filters-example-01-b-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390)                          |
|[filters-felem-01-b-manual](w3cSVGTests/filters-felem-01-b-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390)            |
|[filters-felem-02-f-manual](w3cSVGTests/filters-felem-02-f-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390)            |
|[filters-gauss-01-b-manual](w3cSVGTests/filters-gauss-01-b-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390)           |
|[filters-gauss-02-f-manual](w3cSVGTests/filters-gauss-02-f-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390)            |
|[filters-gauss-03-f-manual](w3cSVGTests/filters-gauss-03-f-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390)            |
|[filters-image-01-b-manual](w3cSVGTests/filters-image-01-b-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390)            |
|[filters-image-02-b-manual](w3cSVGTests/filters-image-02-b-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390)            |
|[filters-image-03-f-manual](w3cSVGTests/filters-image-03-f-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390)            |
|[filters-image-04-f-manual](w3cSVGTests/filters-image-04-f-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390)            |
|[filters-image-05-f-manual](w3cSVGTests/filters-image-05-f-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390)            |
|[filters-light-01-f-manual](w3cSVGTests/filters-light-01-f-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390)            |
|[filters-light-02-f-manual](w3cSVGTests/filters-light-02-f-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390)            |
|[filters-light-03-f-manual](w3cSVGTests/filters-light-03-f-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390)            |
|[filters-light-04-f-manual](w3cSVGTests/filters-light-04-f-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390)            |
|[filters-light-05-f-manual](w3cSVGTests/filters-light-05-f-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390)            |
|[filters-morph-01-f-manual](w3cSVGTests/filters-morph-01-f-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390)                           |
|[filters-offset-01-b-manual](w3cSVGTests/filters-offset-01-b-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390)                           |
|[filters-offset-02-b-manual](w3cSVGTests/filters-offset-02-b-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390)                           |
|[filters-overview-01-b-manual](w3cSVGTests/filters-overview-01-b-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390)                           |
|[filters-overview-02-b-manual](w3cSVGTests/filters-overview-02-b-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390)           |
|[filters-overview-03-b-manual](w3cSVGTests/filters-overview-03-b-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390)                           |
|[filters-specular-01-f-manual](w3cSVGTests/filters-specular-01-f-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390)                          |
|[filters-tile-01-b-manual](w3cSVGTests/filters-tile-01-b-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390)                                  |
|[filters-turb-01-f-manual](w3cSVGTests/filters-turb-01-f-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390)                                 |
|[filters-turb-02-f-manual](w3cSVGTests/filters-turb-02-f-manual.svg)       | [#390](https://github.com/exyte/Macaw/issues/390)                                 |
|[fonts-desc-01-t-manual](w3cSVGTests/fonts-desc-01-t-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[fonts-desc-02-t-manual](w3cSVGTests/fonts-desc-02-t-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[fonts-desc-03-t-manual](w3cSVGTests/fonts-desc-03-t-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[fonts-desc-04-t-manual](w3cSVGTests/fonts-desc-04-t-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[fonts-desc-05-t-manual](w3cSVGTests/fonts-desc-05-t-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[fonts-elem-01-t-manual](w3cSVGTests/fonts-elem-01-t-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[fonts-elem-02-t-manual](w3cSVGTests/fonts-elem-02-t-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[fonts-elem-03-b-manual](w3cSVGTests/fonts-elem-03-b-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[fonts-elem-04-b-manual](w3cSVGTests/fonts-elem-04-b-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[fonts-elem-05-t-manual](w3cSVGTests/fonts-elem-05-t-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[fonts-elem-06-t-manual](w3cSVGTests/fonts-elem-06-t-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[fonts-elem-07-b-manual](w3cSVGTests/fonts-elem-07-b-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[fonts-glyph-02-t-manual](w3cSVGTests/fonts-glyph-02-t-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[fonts-glyph-03-t-manual](w3cSVGTests/fonts-glyph-03-t-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[fonts-glyph-04-t-manual](w3cSVGTests/fonts-glyph-04-t-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[fonts-kern-01-t-manual](w3cSVGTests/fonts-kern-01-t-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[fonts-overview-201-t-manual](w3cSVGTests/fonts-overview-201-t-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[imp-path-01-f-manual](w3cSVGTests/imp-path-01-f-manual.svg)       | [#392](https://github.com/exyte/Macaw/issues/392)     |
|[masking-filter-01-f-manual](w3cSVGTests/masking-filter-01-f-manual.svg)       | [#393](https://github.com/exyte/Macaw/issues/393)  |
|[masking-intro-01-f-manual](w3cSVGTests/masking-intro-01-f-manual.svg)       | ✅               |
|[masking-mask-02-f-manual](w3cSVGTests/masking-mask-02-f-manual.svg)       | [#393](https://github.com/exyte/Macaw/issues/393)                |
|[masking-opacity-01-b-manual](w3cSVGTests/masking-opacity-01-b-manual.svg)       | [#393](https://github.com/exyte/Macaw/issues/393)                |
|[masking-path-01-b-manual](w3cSVGTests/masking-path-01-b-manual.svg)       | [#393](https://github.com/exyte/Macaw/issues/393)                |
|[masking-path-02-b-manual](w3cSVGTests/masking-path-02-b-manual.svg)       | ✅                |
|[masking-path-03-b-manual](w3cSVGTests/masking-path-03-b-manual.svg)       | [#393](https://github.com/exyte/Macaw/issues/393)                |
|[masking-path-04-b-manual](w3cSVGTests/masking-path-04-b-manual.svg)       | [#393](https://github.com/exyte/Macaw/issues/393)                |
|[masking-path-05-f-manual](w3cSVGTests/masking-path-05-f-manual.svg)       | [#393](https://github.com/exyte/Macaw/issues/393)                |
|[masking-path-06-b-manual](w3cSVGTests/masking-path-06-b-manual.svg)       | [wpt issue](https://github.com/web-platform-tests/wpt/issues/11178)  |
|[masking-path-07-b-manual](w3cSVGTests/masking-path-07-b-manual.svg)       | [#393](https://github.com/exyte/Macaw/issues/393)                |
|[masking-path-08-b-manual](w3cSVGTests/masking-path-08-b-manual.svg)       | [#393](https://github.com/exyte/Macaw/issues/393)                |
|[masking-path-10-b-manual](w3cSVGTests/masking-path-10-b-manual.svg)       | [#393](https://github.com/exyte/Macaw/issues/393)                |
|[masking-path-11-b-manual](w3cSVGTests/masking-path-11-b-manual.svg)       | [wpt issue](https://github.com/web-platform-tests/wpt/issues/11178)   |
|[masking-path-13-f-manual](w3cSVGTests/masking-path-13-f-manual.svg)       | [#393](https://github.com/exyte/Macaw/issues/393)                |
|[masking-path-14-f-manual](w3cSVGTests/masking-path-14-f-manual.svg)       | [#393](https://github.com/exyte/Macaw/issues/393)                |
|[metadata-example-01-t-manual](w3cSVGTests/metadata-example-01-t-manual.svg)       | ✅                                                 |
|[painting-control-01-f-manual](w3cSVGTests/painting-control-01-f-manual.svg)       | ✅                                                 |
|[painting-control-02-f-manual](w3cSVGTests/painting-control-02-f-manual.svg)       | ✅                                                 |
|[painting-control-03-f-manual](w3cSVGTests/painting-control-03-f-manual.svg)       | ✅                                                 |
|[painting-control-04-f-manual](w3cSVGTests/painting-control-04-f-manual.svg)       |  [#394](https://github.com/exyte/Macaw/issues/393)  |
|[painting-control-05-f-manual](w3cSVGTests/painting-control-05-f-manual.svg)       | [#393](https://github.com/exyte/Macaw/issues/393)     |
|[painting-control-06-f-manual](w3cSVGTests/painting-control-06-f-manual.svg)       | ✅                                                 |
|[painting-fill-01-t-manual](w3cSVGTests/painting-fill-01-t-manual.svg)       | ✅                                                 |
|[painting-fill-02-t-manual](w3cSVGTests/painting-fill-02-t-manual.svg)       | ✅                                                 |
|[painting-fill-03-t-manual](w3cSVGTests/painting-fill-03-t-manual.svg)       | ✅                                                 |
|[painting-fill-04-t-manual](w3cSVGTests/painting-fill-04-t-manual.svg)       | ✅                                                 |
|[painting-fill-05-b-manual](w3cSVGTests/painting-fill-05-b-manual.svg)       | ✅                                                 |
|[painting-marker-01-f-manual](w3cSVGTests/painting-marker-01-f-manual.svg)       | [#392](https://github.com/exyte/Macaw/issues/392)   |
|[painting-marker-02-f-manual](w3cSVGTests/painting-marker-02-f-manual.svg)       | [#392](https://github.com/exyte/Macaw/issues/392)   |
|[painting-marker-03-f-manual](w3cSVGTests/painting-marker-03-f-manual.svg)       | [#392](https://github.com/exyte/Macaw/issues/392)   |
|[painting-marker-04-f-manual](w3cSVGTests/painting-marker-04-f-manual.svg)       | [#392](https://github.com/exyte/Macaw/issues/392)   |
|[painting-marker-05-f-manual](w3cSVGTests/painting-marker-05-f-manual.svg)       | [#392](https://github.com/exyte/Macaw/issues/392)  |
|[painting-marker-06-f-manual](w3cSVGTests/painting-marker-06-f-manual.svg)       | [#392](https://github.com/exyte/Macaw/issues/392)   |
|[painting-marker-07-f-manual](w3cSVGTests/painting-marker-07-f-manual.svg)       | [#392](https://github.com/exyte/Macaw/issues/392)    |
|[painting-render-01-b-manual](w3cSVGTests/painting-render-01-b-manual.svg)       | [#184](https://github.com/exyte/Macaw/issues/184) |
|[painting-render-02-b-manual](w3cSVGTests/painting-render-02-b-manual.svg)       | [#184](https://github.com/exyte/Macaw/issues/184) |
|[painting-stroke-01-t-manual](w3cSVGTests/painting-stroke-01-t-manual.svg)       | ✅                                                 |
|[painting-stroke-02-t-manual](w3cSVGTests/painting-stroke-02-t-manual.svg)       | ✅                                                 |
|[painting-stroke-03-t-manual](w3cSVGTests/painting-stroke-03-t-manual.svg)       | ✅                                                 |
|[painting-stroke-04-t-manual](w3cSVGTests/painting-stroke-04-t-manual.svg)       | ✅                                                 |
|[painting-stroke-05-t-manual](w3cSVGTests/painting-stroke-05-t-manual.svg)       | ✅                                                 |
|[painting-stroke-06-t-manual](w3cSVGTests/painting-stroke-06-t-manual.svg)       | ✅                                                 |
|[painting-stroke-07-t-manual](w3cSVGTests/painting-stroke-07-t-manual.svg)       | ✅ |
|[painting-stroke-08-t-manual](w3cSVGTests/painting-stroke-08-t-manual.svg)       | ✅                                                 |
|[painting-stroke-09-t-manual](w3cSVGTests/painting-stroke-09-t-manual.svg)       | ✅                                                 |
|[painting-stroke-10-t-manual](w3cSVGTests/painting-stroke-10-t-manual.svg)       |  [#394](https://github.com/exyte/Macaw/issues/394)                                                 |
|[paths-data-01-t-manual](w3cSVGTests/paths-data-01-t-manual.svg)       | ✅                                                 |
|[paths-data-02-t-manual](w3cSVGTests/paths-data-02-t-manual.svg)       | ✅                                                 |
|[paths-data-03-f-manual](w3cSVGTests/paths-data-03-f-manual.svg)       | ✅                                                 |
|[paths-data-04-t-manual](w3cSVGTests/paths-data-04-t-manual.svg)       | ✅                                                 |
|[paths-data-05-t-manual](w3cSVGTests/paths-data-05-t-manual.svg)       | ✅                                                 |
|[paths-data-06-t-manual](w3cSVGTests/paths-data-06-t-manual.svg)       | ✅                                                 |
|[paths-data-07-t-manual](w3cSVGTests/paths-data-07-t-manual.svg)       | ✅                                                 |
|[paths-data-08-t-manual](w3cSVGTests/paths-data-08-t-manual.svg)       | ✅                                                 |
|[paths-data-09-t-manual](w3cSVGTests/paths-data-09-t-manual.svg)       | ✅                                                 |
|[paths-data-10-t-manual](w3cSVGTests/paths-data-10-t-manual.svg)       | ✅                                                 |
|[paths-data-12-t-manual](w3cSVGTests/paths-data-12-t-manual.svg)       | ✅                                                 |
|[paths-data-13-t-manual](w3cSVGTests/paths-data-13-t-manual.svg)       | ✅                                                 |
|[paths-data-14-t-manual](w3cSVGTests/paths-data-14-t-manual.svg)       | ✅                                                 |
|[paths-data-15-t-manual](w3cSVGTests/paths-data-15-t-manual.svg)       | ✅                                                 |
|[paths-data-16-t-manual](w3cSVGTests/paths-data-16-t-manual.svg)       | ✅                                                 |
|[paths-data-17-f-manual](w3cSVGTests/paths-data-17-f-manual.svg)       | ✅                                                 |
|[paths-data-18-f-manual](w3cSVGTests/paths-data-18-f-manual.svg)       | ✅                                                 |
|[paths-data-19-f-manual](w3cSVGTests/paths-data-19-f-manual.svg)       | ✅                                                 |
|[paths-data-20-f-manual](w3cSVGTests/paths-data-20-f-manual.svg)       |  [#395](https://github.com/exyte/Macaw/issues/395)        |
|[pservers-grad-01-b-manual](w3cSVGTests/pservers-grad-01-b-manual.svg)       | ✅                                                 |
|[pservers-grad-02-b-manual](w3cSVGTests/pservers-grad-02-b-manual.svg)       | ✅                                                 |
|[pservers-grad-03-b-manual](w3cSVGTests/pservers-grad-03-b-manual.svg)       |   ✅  |
|[pservers-grad-04-b-manual](w3cSVGTests/pservers-grad-04-b-manual.svg)       | [#396](https://github.com/exyte/Macaw/issues/396)                |
|[pservers-grad-05-b-manual](w3cSVGTests/pservers-grad-05-b-manual.svg)       | [#396](https://github.com/exyte/Macaw/issues/396)                |
|[pservers-grad-06-b-manual](w3cSVGTests/pservers-grad-06-b-manual.svg)       | [#396](https://github.com/exyte/Macaw/issues/396)                |
|[pservers-grad-07-b-manual](w3cSVGTests/pservers-grad-07-b-manual.svg)      | ✅                                                 |
|[pservers-grad-08-b-manual](w3cSVGTests/pservers-grad-08-b-manual.svg)       | [#396](https://github.com/exyte/Macaw/issues/396)                |
|[pservers-grad-09-b-manual](w3cSVGTests/pservers-grad-09-b-manual.svg)       | [#396](https://github.com/exyte/Macaw/issues/396)                |
|[pservers-grad-10-b-manual](w3cSVGTests/pservers-grad-10-b-manual.svg)       | [#396](https://github.com/exyte/Macaw/issues/396)                |
|[pservers-grad-11-b-manual](w3cSVGTests/pservers-grad-11-b-manual.svg)       | [#396](https://github.com/exyte/Macaw/issues/396)                |
|[pservers-grad-12-b-manual](w3cSVGTests/pservers-grad-12-b-manual.svg)       | [#396](https://github.com/exyte/Macaw/issues/396)                |
|[pservers-grad-13-b-manual](w3cSVGTests/pservers-grad-13-b-manual.svg)       | [#396](https://github.com/exyte/Macaw/issues/396)                |
|[pservers-grad-14-b-manual](w3cSVGTests/pservers-grad-14-b-manual.svg)       | [#396](https://github.com/exyte/Macaw/issues/396)                |
|[pservers-grad-15-b-manual](w3cSVGTests/pservers-grad-15-b-manual.svg)       | [#396](https://github.com/exyte/Macaw/issues/396)                |
|[pservers-grad-16-b-manual](w3cSVGTests/pservers-grad-16-b-manual.svg)       | [#396](https://github.com/exyte/Macaw/issues/396)                |
|[pservers-grad-17-b-manual](w3cSVGTests/pservers-grad-17-b-manual.svg)       | [#396](https://github.com/exyte/Macaw/issues/396)                |
|[pservers-grad-18-b-manual](w3cSVGTests/pservers-grad-18-b-manual.svg)       | [#396](https://github.com/exyte/Macaw/issues/396)                |
|[pservers-grad-20-b-manual](w3cSVGTests/pservers-grad-20-b-manual.svg)       | [#396](https://github.com/exyte/Macaw/issues/396)                |
|[pservers-grad-21-b-manual](w3cSVGTests/pservers-grad-21-b-manual.svg)       | [#396](https://github.com/exyte/Macaw/issues/396)                |
|[pservers-grad-22-b-manual](w3cSVGTests/pservers-grad-22-b-manual.svg)       | [#396](https://github.com/exyte/Macaw/issues/396)                |
|[pservers-grad-23-f-manual](w3cSVGTests/pservers-grad-23-f-manual.svg)       | [#396](https://github.com/exyte/Macaw/issues/396)                |
|[pservers-grad-24-f-manual](w3cSVGTests/pservers-grad-24-f-manual.svg)       | [#396](https://github.com/exyte/Macaw/issues/396)                |
|[pservers-grad-stops-01-f-manual](w3cSVGTests/pservers-grad-stops-01-f-manual.svg)       | ✅                                                 |
|[pservers-pattern-01-b-manual](w3cSVGTests/pservers-pattern-01-b-manual.svg)       | [#203](https://github.com/exyte/Macaw/issues/203)  |
|[pservers-pattern-02-f-manual](w3cSVGTests/pservers-pattern-02-f-manual.svg)       | [#203](https://github.com/exyte/Macaw/issues/203)  |
|[pservers-pattern-03-f-manual](w3cSVGTests/pservers-pattern-03-f-manual.svg)       | [#203](https://github.com/exyte/Macaw/issues/203)  |
|[pservers-pattern-04-f-manual](w3cSVGTests/pservers-pattern-04-f-manual.svg)       | [#203](https://github.com/exyte/Macaw/issues/203)  |
|[pservers-pattern-05-f-manual](w3cSVGTests/pservers-pattern-05-f-manual.svg)       | [#203](https://github.com/exyte/Macaw/issues/203)  |
|[pservers-pattern-06-f-manual](w3cSVGTests/pservers-pattern-06-f-manual.svg)       | [#203](https://github.com/exyte/Macaw/issues/203)  |
|[pservers-pattern-07-f-manual](w3cSVGTests/pservers-pattern-07-f-manual.svg)       | [#203](https://github.com/exyte/Macaw/issues/203)  |
|[pservers-pattern-08-f-manual](w3cSVGTests/pservers-pattern-08-f-manual.svg)       | [#203](https://github.com/exyte/Macaw/issues/203)  |
|[pservers-pattern-09-f-manual](w3cSVGTests/pservers-pattern-09-f-manual.svg)       | [#203](https://github.com/exyte/Macaw/issues/203)  |
|[render-elems-01-t-manual](w3cSVGTests/render-elems-01-t-manual.svg)       | ✅                                                 |
|[render-elems-02-t-manual](w3cSVGTests/render-elems-02-t-manual.svg)       | ✅                                                 |
|[render-elems-03-t-manual](w3cSVGTests/render-elems-03-t-manual.svg)       | ✅                                                 |
|[render-groups-01-b-manual](w3cSVGTests/render-groups-01-b-manual.svg)       | [wpt issue](https://github.com/web-platform-tests/wpt/issues/11178)  |
|[render-groups-03-t-manual](w3cSVGTests/render-groups-03-t-manual.svg)       | [wpt issue](https://github.com/web-platform-tests/wpt/issues/11178)  |
|[shapes-circle-01-t-manual](w3cSVGTests/shapes-circle-01-t-manual.svg) | ✅                                                |
|[shapes-circle-02-t-manual](w3cSVGTests/shapes-circle-02-t-manual.svg)       | ✅                                                 |
|[shapes-ellipse-01-t-manual](w3cSVGTests/shapes-ellipse-01-t-manual.svg)       | ✅                                                 |
|[shapes-ellipse-02-t-manual](w3cSVGTests/shapes-ellipse-02-t-manual.svg)       | ✅                                                 |
|[shapes-ellipse-03-f-manual](w3cSVGTests/shapes-ellipse-03-f-manual.svg)       | ✅                                                 |
|[shapes-grammar-01-f-manual](w3cSVGTests/shapes-grammar-01-f-manual.svg)       | ✅                                                 |
|[shapes-intro-01-t-manual](w3cSVGTests/shapes-intro-01-t-manual.svg)       | ✅                                                 |
|[shapes-intro-02-f-manual](w3cSVGTests/shapes-intro-02-f-manual.svg)       | [ios issue](https://stackoverflow.com/questions/50329506/creating-uibezierpath-from-an-arc-adds-extra-line)                                             |
|[shapes-line-01-t-manual](w3cSVGTests/shapes-line-01-t-manual.svg)       | ✅                                                 |
|[shapes-line-02-f-manual](w3cSVGTests/shapes-line-02-f-manual.svg)       | ✅                                                 |
|[shapes-polygon-01-t-manual](w3cSVGTests/shapes-polygon-01-t-manual.svg)       | ✅                                                 |
|[shapes-polygon-02-t-manual](w3cSVGTests/shapes-polygon-02-t-manual.svg)       | ✅                                                 |
|[shapes-polygon-03-t-manual](w3cSVGTests/shapes-polygon-03-t-manual.svg)       | ✅                                                 |
|[shapes-polyline-01-t-manual](w3cSVGTests/shapes-polyline-01-t-manual.svg)       | ✅                                                 |
|[shapes-polyline-02-t-manual](w3cSVGTests/shapes-polyline-02-t-manual.svg)       | ✅                                                 |
|[shapes-rect-02-t-manual](w3cSVGTests/shapes-rect-02-t-manual.svg)       |  [ios bug](https://stackoverflow.com/q/18880919)|
|[shapes-rect-03-t-manual](w3cSVGTests/shapes-rect-03-t-manual.svg)       |  [ios bug](https://stackoverflow.com/q/18880919)|
|[shapes-rect-04-f-manual](w3cSVGTests/shapes-rect-04-f-manual.svg)       | ✅                                                 |
|[shapes-rect-05-f-manual](w3cSVGTests/shapes-rect-05-f-manual.svg)       | ✅                                                 |
|[shapes-rect-06-f-manual](w3cSVGTests/shapes-rect-06-f-manual.svg)       |  [ios bug](https://stackoverflow.com/q/18880919)                                                 |
|[shapes-rect-07-f-manual](w3cSVGTests/shapes-rect-07-f-manual.svg)       |  [ios bug](https://stackoverflow.com/q/18880919)                                                 |
|[struct-defs-01-t-manual](w3cSVGTests/struct-defs-01-t-manual.svg)       | ✅                                                 |
|[struct-frag-01-t-manual](w3cSVGTests/struct-frag-01-t-manual.svg)       | ✅                                                 |
|[struct-frag-02-t-manual](w3cSVGTests/struct-frag-02-t-manual.svg)       | ✅                                                 |
|[struct-frag-03-t-manual](w3cSVGTests/struct-frag-03-t-manual.svg)       | ✅                                                 |
|[struct-frag-04-t-manual](w3cSVGTests/struct-frag-04-t-manual.svg)       | ✅                                                 |
|[struct-frag-05-t-manual](w3cSVGTests/struct-frag-05-t-manual.svg)       | [#397](https://github.com/exyte/Macaw/issues/397)  |
|[struct-frag-06-t-manual](w3cSVGTests/struct-frag-06-t-manual.svg)       | ✅                                                 |
|[struct-group-01-t-manual](w3cSVGTests/struct-group-01-t-manual.svg)       | ✅                                                 |
|[struct-group-02-b-manual](w3cSVGTests/struct-group-02-b-manual.svg)       | [#344](https://github.com/exyte/Macaw/issues/344)   |
|[struct-group-03-t-manual](w3cSVGTests/struct-group-03-t-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)    |
|[struct-image-01-t-manual](w3cSVGTests/struct-image-01-t-manual.svg)       | [wpt issue](https://github.com/web-platform-tests/wpt/issues/11178)                 |
|[struct-image-02-b-manual](w3cSVGTests/struct-image-02-b-manual.svg)       | [wpt issue](https://github.com/web-platform-tests/wpt/issues/11178)                 |
|[struct-image-03-t-manual](w3cSVGTests/struct-image-03-t-manual.svg)       | [wpt issue](https://github.com/web-platform-tests/wpt/issues/11178)                 |
|[struct-image-04-t-manual](w3cSVGTests/struct-image-04-t-manual.svg)       | [wpt issue](https://github.com/web-platform-tests/wpt/issues/11178)                 |
|[struct-image-05-b-manual](w3cSVGTests/struct-image-05-b-manual.svg)       | [wpt issue](https://github.com/web-platform-tests/wpt/issues/11178)                 |
|[struct-image-06-t-manual](w3cSVGTests/struct-image-06-t-manual.svg)       | [wpt issue](https://github.com/web-platform-tests/wpt/issues/11178)                 |
|[struct-image-07-t-manual](w3cSVGTests/struct-image-07-t-manual.svg)       | [wpt issue](https://github.com/web-platform-tests/wpt/issues/11178)                 |
|[struct-image-08-t-manual](w3cSVGTests/struct-image-08-t-manual.svg)       | [wpt issue](https://github.com/web-platform-tests/wpt/issues/11178)                 |
|[struct-image-09-t-manual](w3cSVGTests/struct-image-09-t-manual.svg)       | [wpt issue](https://github.com/web-platform-tests/wpt/issues/11178)                 |
|[struct-image-10-t-manual](w3cSVGTests/struct-image-10-t-manual.svg)       | [wpt issue](https://github.com/web-platform-tests/wpt/issues/11178)                 |
|[struct-image-11-b-manual](w3cSVGTests/struct-image-11-b-manual.svg)       | [wpt issue](https://github.com/web-platform-tests/wpt/issues/11178)                 |
|[struct-image-12-b-manual](w3cSVGTests/struct-image-12-b-manual.svg)       | [wpt issue](https://github.com/web-platform-tests/wpt/issues/11178)                 |
|[struct-image-13-f-manual](w3cSVGTests/struct-image-13-f-manual.svg)       | [wpt issue](https://github.com/web-platform-tests/wpt/issues/11178)                 |
|[struct-image-14-f-manual](w3cSVGTests/struct-image-14-f-manual.svg)       | [wpt issue](https://github.com/web-platform-tests/wpt/issues/11178)                 |
|[struct-image-15-f-manual](w3cSVGTests/struct-image-15-f-manual.svg)       | [wpt issue](https://github.com/web-platform-tests/wpt/issues/11178)                 |
|[struct-image-16-f-manual](w3cSVGTests/struct-image-16-f-manual.svg)       | [wpt issue](https://github.com/web-platform-tests/wpt/issues/11178)                 |
|[struct-image-17-b-manual](w3cSVGTests/struct-image-17-b-manual.svg)       | [wpt issue](https://github.com/web-platform-tests/wpt/issues/11178)                 |
|[struct-image-18-f-manual](w3cSVGTests/struct-image-18-f-manual.svg)       | [wpt issue](https://github.com/web-platform-tests/wpt/issues/11178)                 |
|[struct-image-19-f-manual](w3cSVGTests/struct-image-19-f-manual.svg)       | [wpt issue](https://github.com/web-platform-tests/wpt/issues/11178)                 |
|[struct-svg-03-f-manual](w3cSVGTests/struct-svg-03-f-manual.svg)       | [#344](https://github.com/exyte/Macaw/issues/344)   |
|[struct-symbol-01-b-manual](w3cSVGTests/struct-symbol-01-b-manual.svg)       | [#398](https://github.com/exyte/Macaw/issues/398)                                                  |
|[struct-use-01-t-manual](w3cSVGTests/struct-use-01-t-manual.svg)       | [#399](https://github.com/exyte/Macaw/issues/399)  |
|[struct-use-03-t-manual](w3cSVGTests/struct-use-03-t-manual.svg)       | ✅                                                 |
|[struct-use-09-b-manual](w3cSVGTests/struct-use-09-b-manual.svg)       | [#398](https://github.com/exyte/Macaw/issues/398)  |
|[struct-use-12-f-manual](w3cSVGTests/struct-use-12-f-manual.svg)       | ✅                                                 |
|[text-align-01-b-manual](w3cSVGTests/text-align-01-b-manual.svg)       | ✅                                                 |
|[text-align-02-b-manual](w3cSVGTests/text-align-02-b-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-align-03-b-manual](w3cSVGTests/text-align-03-b-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-align-04-b-manual](w3cSVGTests/text-align-04-b-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-align-05-b-manual](w3cSVGTests/text-align-05-b-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-align-06-b-manual](w3cSVGTests/text-align-06-b-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-align-07-t-manual](w3cSVGTests/text-align-07-t-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-align-08-b-manual](w3cSVGTests/text-align-08-b-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-bidi-01-t-manual](w3cSVGTests/text-bidi-01-t-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-deco-01-b-manual](w3cSVGTests/text-deco-01-b-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-fonts-01-t-manual](w3cSVGTests/text-fonts-01-t-manual.svg)       | ✅                                                 |
|[text-fonts-02-t-manual](w3cSVGTests/text-fonts-02-t-manual.svg)       | ✅                                                 |
|[text-fonts-03-t-manual](w3cSVGTests/text-fonts-03-t-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-fonts-04-t-manual](w3cSVGTests/text-fonts-04-t-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-fonts-05-f-manual](w3cSVGTests/text-fonts-05-f-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-fonts-202-t-manual](w3cSVGTests/text-fonts-202-t-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-fonts-203-t-manual](w3cSVGTests/text-fonts-203-t-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-fonts-204-t-manual](w3cSVGTests/text-fonts-204-t-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-intro-01-t-manual](w3cSVGTests/text-intro-01-t-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-intro-02-b-manual](w3cSVGTests/text-intro-02-b-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-intro-03-b-manual](w3cSVGTests/text-intro-03-b-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-intro-04-t-manual](w3cSVGTests/text-intro-04-t-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-intro-05-t-manual](w3cSVGTests/text-intro-05-t-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-intro-06-t-manual](w3cSVGTests/text-intro-06-t-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-intro-07-t-manual](w3cSVGTests/text-intro-07-t-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-intro-09-b-manual](w3cSVGTests/text-intro-09-b-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-intro-10-f-manual](w3cSVGTests/text-intro-10-f-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-intro-11-t-manual](w3cSVGTests/text-intro-11-t-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-intro-12-t-manual](w3cSVGTests/text-intro-12-t-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-path-01-b-manual](w3cSVGTests/text-path-01-b-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-path-02-b-manual](w3cSVGTests/text-path-02-b-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-spacing-01-b-manual](w3cSVGTests/text-spacing-01-b-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-text-01-b-manual](w3cSVGTests/text-text-01-b-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-text-03-b-manual](w3cSVGTests/text-text-03-b-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-text-04-t-manual](w3cSVGTests/text-text-04-t-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-text-05-t-manual](w3cSVGTests/text-text-05-t-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-text-06-t-manual](w3cSVGTests/text-text-06-t-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-text-07-t-manual](w3cSVGTests/text-text-07-t-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-text-08-b-manual](w3cSVGTests/text-text-08-b-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-text-09-t-manual](w3cSVGTests/text-text-09-t-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-text-10-t-manual](w3cSVGTests/text-text-10-t-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-text-11-t-manual](w3cSVGTests/text-text-11-t-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-text-12-t-manual](w3cSVGTests/text-text-12-t-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-tref-01-b-manual](w3cSVGTests/text-tref-01-b-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-tref-02-b-manual](w3cSVGTests/text-tref-02-b-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-tref-03-b-manual](w3cSVGTests/text-tref-03-b-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-tspan-01-b-manual](w3cSVGTests/text-tspan-01-b-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[text-tspan-02-b-manual](w3cSVGTests/text-tspan-02-b-manual.svg)       | [#391](https://github.com/exyte/Macaw/issues/391)                                         |
|[types-basic-01-f-manual](w3cSVGTests/types-basic-01-f-manual.svg)       | ✅                                               |
