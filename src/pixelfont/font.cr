require "./grapheme"
require "./parser"

module Pixelfont
  class Font
    getter graphemes = {} of Char => Grapheme

    property line_height : UInt16 = 0
    property leading : Int16 = 1  # space between lines
    property tracking : Int16 = 1 # space between glyphs

    def initialize(path : String)
      File.open(path, "r") do |file|
        @graphemes = Pixelfont::Parser.new(file).parse
      end
      @line_height = @graphemes.values.max_of(&.height)
    end

    def initialize(io : IO)
      @graphemes = Pixelfont::Parser.new(io).parse
      @line_height = @graphemes.values.max_of(&.height)
    end

    def initialize(@graphemes)
      @line_height = @graphemes.values.max_of(&.height)
    end

    # Provides (x, y) cordinates and if the pixel is on
    #
    # ```
    # font.draw("Hello, World!") do |px, py, bit|
    #   my_screen[px, py] = RGB.new(0, 0, 0) if bit
    # end
    # ```
    #
    def draw(string : String, x = 0, y = 0, &block : Int32, Int32, Bool ->)
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

          0.upto(g.height - 1) do |cy|
            0.upto(g.width - 1) do |cx|
              if mask == 0
                mask = 0b1000_0000_u8
                bits = g.data[byte]? || 0u8
                byte += 1
              end

              fx = (x + cur_x) + cx
              fy = (y + cur_y) + cy

              yield fx, fy, mask & bits > 0

              mask >>= 1
            end
          end

          cur_x += g.width + @tracking
        else
          STDERR.puts "Pixelfont: Unknown grapheme '#{g}'"
        end
      end
    end

    def width_of(string : String)
      widths = string.chars.map do |char|
        if char = @graphemes[char]?
          char.width.to_i32
        else
          0
        end
      end

      widths.sum + (@tracking * (string.size - 1))
    end

    def height_of(string : String)
      lines = string.lines.size
      (lines * @line_height) + ((lines - 1) * @leading)
    end

    def to_s(string : String, fore : Char = '█', back : Char = ' ')
      width = width_of(string)
      height = height_of(string)

      buffer = Array(Array(Char)).new(height) { Array(Char).new(width) { back } }

      draw(string) do |x, y, on|
        buffer[y][x] = fore if on
      end

      buffer.map(&.join).join("\n")
    end
  end
end
