require "./grapheme"
require "./parser"

module Pixelfont
  @[Flags]
  enum Properties : UInt32
    OnlyCaps
  end

  class Font
    getter graphemes = {} of Char => Grapheme

    property line_height : UInt16 = 0
    property leading : Int16 = 1  # space between lines
    property tracking : Int16 = 1 # space between glyphs
    property properties : Properties = Properties::None

    def initialize(path : String)
      File.open(path, "r") { |file| initialize(file) }
    end

    def initialize(io : IO)
      @properties, @graphemes = Pixelfont::Parser.new(io).parse
      @line_height = @graphemes.values.max_of(&.height)
    end

    def initialize(@graphemes, @properties = Properties::None)
      @line_height = @graphemes.values.max_of(&.height)
    end

    # em width or set width of the font
    getter set_width : UInt16 do
      @graphemes.max_of { |(_, g)| g.width } || 0u16
    end

    # Provides (x, y) cordinates and if the pixel is on
    #
    # ```
    # font.draw("Hello, World!") do |px, py, bit|
    #   my_screen[px, py] = RGB.new(0, 0, 0) if bit
    # end
    # ```
    #
    def draw(string : String, x = 0, y = 0, fixed_width = false, &block : Int32, Int32, Bool ->)
      string = string.upcase if @properties.only_caps?
      cur_y = 0
      cur_x = 0

      string.chars.each do |c|
        if c == '\n'
          cur_y += @line_height + @leading
          cur_x = 0
          next
        end

        if g = @graphemes[c]?
          byte = 0
          bits = uninitialized UInt8
          mask = 0u8

          offset = fixed_width ? (set_width - g.width) // 2 : 0

          0.upto(g.height - 1) do |cy|
            0.upto(g.width - 1) do |cx|
              if mask == 0
                mask = 0b1000_0000_u8
                bits = g.data[byte]? || 0u8
                byte += 1
              end

              fx = (x + cur_x) + cx + offset
              fy = (y + cur_y) + cy

              yield fx, fy, mask & bits > 0

              mask >>= 1
            end
          end

          cur_x += (fixed_width ? set_width : g.width) + @tracking
        else
          STDERR.puts "Pixelfont: Unknown grapheme '#{c}'"
        end
      end
    end

    def width_of(string : String, fixed_width = false)
      if fixed_width
        string.lines.max_of do |line|
          (line.size * (set_width + @tracking)) - @tracking
        end
      else
        string.lines.max_of do |line|
          widths = line.chars.map do |char|
            @graphemes[char]?.try(&.width.to_i32) || 0
          end

          widths.sum + (@tracking * (line.size - 1))
        end
      end
    end

    def height_of(string : String)
      (string.lines.size * (@line_height + @leading)) - @leading
    end

    def to_s(string : String, fore : Char = '█', back : Char = ' ', fixed_width = false)
      string = string.upcase if @properties.only_caps?

      width = width_of(string, fixed_width)
      height = height_of(string)

      buffer = Array(Array(Char)).new(height) { Array(Char).new(width) { back } }

      draw(string, fixed_width: fixed_width) do |x, y, on|
        buffer[y][x] = fore if on
      end

      buffer.map(&.join).join("\n")
    end
  end
end
