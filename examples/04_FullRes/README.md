# Full Res

<img width="480" alt="FullRes" src="https://openfpgatutorials.org/assets/blog/2023-06-23/FullRes.png">
<p></p>

This core displays a color gradient square, similar to the Color Test core but this time in glorious 800x720 resolution (the maximum resolution available on the Pocket).

### Code analysis

The code is exactly the same as the Color Test core but the pixel clock is running at 44.280Mhz instead of 12.288Mhz. This is achieved by changing the settings on the Pocket's PLL chip and that is why this core is using a different core template than the other one since PLL settings are part of the IP settings in the Quartus projects.

Finally the parameters in `display.v` are tweaked to fit the new resolution:
```
localparam signed HORIZONTAL_TOTAL = COORD_WIDTH'(900);
localparam signed VERTICAL_TOTAL = COORD_WIDTH'(820);

localparam signed HORIZONTAL_RESOLUTION = COORD_WIDTH'(800);
localparam signed VERTICAL_RESOLUTION = COORD_WIDTH'(720);
```

More info on how to modify clock signals can be found in the [tutorials](https://openfpgatutorials.org/docs/openFPGA-FAQ#change-clock-signal) docs.

**NOTE:** The **Analogue Pocket**'s screen resolution is actually 1600x1440 but a core can [only go up](https://www.analogue.co/developer/docs/bus-communication#video) to half of that with a max pixel clock of ~50Mhz.
