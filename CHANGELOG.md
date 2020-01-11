# 1.5.0
* Added packer configuration.
* Changed default max-rect heuristic to `BestLongSideFit` as it produce more compact results.
* Cahnged default sort to descending height (`-height`)
* Fixed graphical corruption when using padding with `raster` mode
* Mitigated graphical corruption on sdf due to normalization of a single dot.

# 1.4.0
* Added `everything` charset: Covers all unicode blocks.
* When using `everything` charset missing character counter is disabled
* When `charset` is not present in font config or is empty - `everything` is used.
* Added `LATIN1_SUPPLEMENT` to `LATIN` and `ANSI` aliases
* Added `ASCII` alias that covers `BASIC_LATIN` and `NONPRINTING`

# 1.3.0
* Added `r8raster` to use greyscale non-alpha image for rasterized glyphs.
* Fixed crash on same-directory config paths

# 1.2.0
* Added better solution for counter-clockwise glyphs.
* Removed `fixwinding` options (always-on from now on)
* Removed sdf chunk from .fnt file when in raster mode.

# 1.1.0
* Added config options feature
* Added `fixwinding` option to fix counter-clockwise glyphs.
* Added `allownonprinting` option to enable nonprinting range of characters
* Disabled nonprinting characters by default
* Added support for 1-bit (pure black and white) fonts in raster mode.

# 1.0.0
Initial release