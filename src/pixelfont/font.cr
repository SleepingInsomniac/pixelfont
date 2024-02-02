require "./glyph"

module Pixelfont
  class Font
    getter glyphs = {} of Char => Glyph

    property line_height : UInt8 = 0 # height of glyphs
    property leading : Int8 = 1      # space between lines
    property tracking : Int8 = 1     # space between glyphs

    def initialize(path : String)
      File.open(path, "r") do |file|
        initialize(file)
      end
    end

    def initialize(io : IO)
      state = :read_char
      char_def = uninitialized Char
      char_width = 0u8
      char_height = 0u8
      char_bits = 0u64
      mask = 1u64 << 63
      @line_height = 0u8

      while line = io.gets("\n", true)
        case state
        when :read_char
          next if line.blank?
          char_def = line.size > 1 ? line[1] : line[0]
          state = :get_data
        when :get_data
          if line.blank?
            @line_height = char_height if char_height > @line_height
            @glyphs[char_def] = Glyph.new(char_bits, char_width, char_height)
            char_width = 0u8
            char_height = 0u8
            char_bits = 0u64
            mask = 1u64 << 63
            state = :read_char
          else
            char_height += 1
            char_width = line.size.to_u8 if line.size > char_width
            line.chars.each do |char|
              char_bits |= mask if char != '.'
              mask >>= 1
            end
          end
        end
      end

      @glyphs[char_def] = Glyph.new(char_bits, char_width, char_height)
    end

    # Provides (x, y) cordinates and a bool for bits in a glyph matrix
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

        if glyph = @glyphs[c]?
          mask = 1_u64 << 63

          0.upto(glyph.height - 1) do |cy|
            0.upto(glyph.width - 1) do |cx|
              fx = (x + cur_x) + cx
              fy = (y + cur_y) + cy
              yield fx, fy, mask & glyph.bits > 0
              mask >>= 1
            end
          end

          cur_x += glyph.width + @tracking
        else
          STDERR.puts "Pixelfont: Unknown glyph '#{glyph}'"
        end
      end
    end

    def width_of(string : String)
      widths = string.chars.map do |char|
        if char = @glyphs[char]?
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
