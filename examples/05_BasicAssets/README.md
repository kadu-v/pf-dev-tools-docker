# Basic Assets

<img width="240" alt="BasicAssets1" src="https://openfpgatutorials.org/assets/blog/2023-09-20/BasicAssets1.png">
<img width="240" alt="BasicAssets2" src="https://openfpgatutorials.org/assets/blog/2023-09-20/BasicAssets2.png">
<img width="240" alt="BasicAssets3" src="https://openfpgatutorials.org/assets/blog/2023-09-20/BasicAssets3.png">
<p></p>

This core replicates exactly the **openFPGA** [core-example-basicassets](https://github.com/open-fpga/core-example-basicassets) and demonstrates loading and displaying a static image and audio from selectable asset files out of RAM. A square is also drawn over the top of the image, which can be controlled with user input.

It's included here because, during research for using the BRIDGE in my own core, I ended up trying to build it locally in order to try and understand more about how it works and was reminded that the JSON files interface is very error-prone. I decided to port the core to the [pf-dev-tools](https://pypi.org/project/pf-dev-tools/) toolchain in order to add all the missing functionality regarding files, variables and controllers.

For the time being, and since this is one of **Analogue**'s own samples, the core's code won't be documented here. We will focus on the configuration instead.

### Config analysis

As usual, the core's entire configuration is found in `src/config.toml`. As a reminder, you can find the entire documentation for [core configuration](https://codeberg.org/DidierMalenfant/pfDevTools#core-config-file-format) in **pf-dev-tools**'s README.

The `[Platform]`, `[Build]`, `[Author]` and `[Hardware]` sections are very similar to other core's configuration. The other sections are where the magic happens.

#### `[Variables]` section

Variables are values that are exposed in the **Pocket**'s `Core Settings` menu. In this example the core uses one value, with id `1`, named `Screen Border`. This is a checkmark that defaults to `true`. If the checkmark is checked, the value `1` is written at address `0x50000000` on the **openFPGA BRIDGE**. Finally, the variable is marked as persistent which means it retains its value between separate launches of the core.

In the config file, this looks like this:
```
[Variables]
    [Variables.1]
    name = "Screen Border"
    type = "check"
    enabled = true
    persistent = true
    address = "0x50000000"
    default = true
    value_on = 1
    mask = "0xFFFF0000"
```

When using the core, you can switch the colorful screen border on/off using this setting.

#### `[Controllers]` section

The **Pocket**'s `Core Settings` menu also has an entry named `Controls`. This allows the user to remap controls and the `[Controllers]` section provide default mappings for this.

This core provides one controller mapping, also with id `1`, which defines three keys: `Purple Square`, `Green Square` and `Replay Audio`. The default mappings are `A`, `B` and `X` but they could also be `Y`, `L`, `R`, `Start` or `Select`.

In the config file, this looks like this:
```
[Controllers]
    [Controllers.1]
    key_mapping = [ [ "Purple Square", "A" ],
                    [ "Green Square", "B" ],
                    [ "Replay Audio", "X" ] ]
```

#### `[Files]` section

Finally the config file provides information on two files, with ids `1` and `99`, which the core use for displaying a background picture and playing a sound file. Both files are required and both files cause some external assets to be included in the core package but none of those assets are marked as being loaded when the core starts so, instead, **openFPGA** will ask the user to pick each file before starting the core. It will use the extensions provided to only display compatible files in its request dialog.

In the config file, this looks like this:
```
[Files]
    [Files.1]
    name = "Background"
    required = true
    parameters = [ "user-reloadable", "core-specific" ]
    extensions = [ "bin" ]
    required_size = 184320
    address = "0x00000000"
    include_files = [ "assets/images/ex_image_1.bin", "assets/images/ex_image_2.bin", "assets/images/ex_image_3.bin" ]

    [Files.99]
    name = "Audio"
    required = true
    parameters = [ "user-reloadable", "core-specific" ]
    extensions = [ "wav" ]
    maximum_size = "0x3C00000"
    address = "0x00400000"
    include_files = [ "assets/audio/ex_audio_1.wav", "assets/audio/ex_audio_2.wav" ]
```
