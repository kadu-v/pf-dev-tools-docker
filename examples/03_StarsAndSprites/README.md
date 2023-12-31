# Stars and Sprites

<img width="480" alt="StarsAndSprites" src="https://openfpgatutorials.org/assets/blog/2023-05-25/StarsAndSprites.png">
<p></p>

This core displays a complex starfield and some sprites with an old school color-gradient. It is based on the [AD ASTRA](https://projectf.io/posts/fpga-ad-astra/) demo in Will Green's [Project F](https://projectf.io) blog but a similar project can be found in Steven Hugg's [Designing Video Game Hardware in Verilog](https://www.amazon.com/Designing-Video-Game-Hardware-Verilog/dp/1728619440).

This is a great example of how complex designs can be split into simple modules that are connected together.

### Code analysis

The main module here is `display` which uses a lot of other modules to generate the video sync signals and the `video_rgb` signal for indicating a pixel's color:
```
video_rgb = video_enable ? (spr_pixel_on ? copper_rgb : star_rgb) : { 8'd0, 8'd0, 8'd0 };
```

Here if `video_enable` is off then pixels are black. Otherwise if `spr_pixel_on` is 1, which means that one of the sprite's pixel is active, then the pixel uses `copper_rgb` from the copper module. Otherwise it uses the `star_rgb` color from the star fields. This establishes the priority on screen of the various parts being displayed.

Note that `video_rgb` is generated inside a combinational (`always_comb`) block which mean it uses a blocking assignment (`=`). This is because the value of this signal always the result of combining its input signals and doesn't require any sequential logic. `video_rgb` is declared as a `logic` which means the compiler is free to generate it using a constantly driven wire or a flip-flop.

Now let's look at each module individually. First up `video_sync` is simply generates all the video syncing signals, similarly to how the Color Test example does but nicely separated out in its own module. All other modules generate their output based on the pixel coordinates generated by the `video_sync` module.

The `copper` module generates a color based on the pixel's vertical position, similarly to how the Amiga's copper chip would allow you to change a palette color based on vertical position of the beam. The design is fairly straightforward and generates two color gradients, one blue and one brown.

`starfields` is a collection of three `starfield` modules. It generates a single `pixel_rgb` signal based on the resulting pixel signals from those three starfields.

The `starfield` module uses an `lfsr` module which is an implementation of a [Linear-feedback shift register](https://en.wikipedia.org/wiki/Linear-feedback_shift_register). This basically generates a random value given a seed value. The interesting part here is that we are guaranteed that each possible value will be generated only once and that the sequence of values can be re-generated exactly the same given the same seed or a given value in the sequence. This is key to how the stars are generated and animated as we'll see later on.

To produce a color for a given pixel, `starfield` sets up the shirt register to generate values for **ALL** pixels produced by the display, visible or invisible. For each of those values, if uses the lower part of the value to determine if the pixel in on or not. The higher part of the value can then be used for the star's brightness if the pixel is on.

Now, since value are generated linearly as the pixels are processed by the `video_sync` module, values end up automatically continuing after the end of one line onto the beginning of the next line. All we have to do to animate the starfield and make it scroll it then to increment the starting value of the shift register every frame. All values produced remain the same, just shifted slightly to the right.

In order to produce a parallax effect the three starfields are set up with different scrolling speeds.

The `sprites` module is a collection of four `sprite` modules. It generates a single `pixel_on` signal which is 1 if any of the sprites have a pixel enabled at that location. It also uses a `rom_sync` module to create synchronous read-only memory which contain the font used by the sprites. Arrays contain position and content (letter to display) for each sprite which allows us to use the `generate` statement in order to generate each `sprite` module without having to type the same information multiple times.

Finally the `sprite` module figures out if a pixel from the sprite should be drawn at the current pixel position. It supports scaling and flipping the sprite. It also uses a state machine to make sure accesses to the `rom_sync` are not colliding with other sprites in the system. Each sprite waits for its turn before reading its data for the current line.
