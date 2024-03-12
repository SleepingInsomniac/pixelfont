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

```zsh
shards build --release
./bin/pixelfont -f fonts/pixel-5x7 display "Hello, World!"
```

## Contributing

1. Fork it (<https://github.com/sleepinginsomniac/pixelfont/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Alex Clink](https://github.com/sleepinginsomniac) - creator and maintainer
