# Pixelfont

    ████
    █   █   █               ███     ██               █
    █   █       █   █  ███    █    █  █  ███  █ ██  █████
    ████  ███    █ █  █   █   █    █    █   █ ██  █  █
    █       █     █   █████   █   ███   █   █ █   █  █
    █       █    █ █  █       █    █    █   █ █   █  █
    █      ███  █   █  ████   ███  █     ███  █   █   ██

When you want a font, but are kinda lazy.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     pixelfont:
       github: sleepinginsomniac/pixelfont
   ```

2. Run `shards install`

## Usage

```crystal
require "pixelfont"

font = Pixelfont::Font.new

font.draw("Hello, World!") do |px, py, on|
  my_screen[px, py] = RGB.new(0, 0, 0) if on
end
```

## Cli

    shards build --release

    # Write text as an array of characters
    ./bin/pixelfont -i fonts/pixel-5x7.txt display "Hello, World!"

    # Export as binary
    ./bin/pixelfont -i fonts/pixel-5x7.txt export -o pixel-5x7.pxf -f binary

    # Get the bytes for embeding
    ./bin/pixelfont -i fonts/pixel-5x7.txt embed

## Contributing

1. Fork it (<https://github.com/sleepinginsomniac/pixelfont/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Alex Clink](https://github.com/sleepinginsomniac) - creator and maintainer
