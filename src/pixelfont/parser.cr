require "./grapheme"

module Pixelfont
  class Parser
    enum State
      Reset
      ReadChar
      ReadData
      Done
    end

    @state = State::Reset
    @io : IO

    @graphemes = {} of Char => Grapheme
    @current = uninitialized Grapheme
    @char = uninitialized Char
    @string = ""
    @data = IO::Memory.new

    def initialize(@io)
    end

    def parse
      until @state.done?
        case @state
        when .reset?     then reset
        when .read_char? then read_char
        when .read_data? then read_data
        when .done?
        end
      end

      store_grapheme
      @graphemes
    end

    def reset
      @current.width = 0
      @current.height = 0
      @string = ""
      @data.clear
      @state = State::ReadChar
    end

    def read_char
      return unless line = read_line
      return if line.blank? # Skip blank lines

      # Allow a char to be wrapped in quotes
      @char = line.size > 1 ? line[1] : line[0]
      @state = State::ReadData
    end

    def read_data
      return unless line = read_line

      if line.blank?
        store_grapheme
        @state = State::Reset
      else
        @current.height += 1
        @current.width = line.size.to_u16 if line.size > @current.width
        @string += line
      end
    end

    def store_grapheme
      pack_data(@string, @data)
      @current.data = @data.to_slice.dup
      @graphemes[@char] = @current
    end

    # Get the next line, if nil EOF is reached
    def read_line : String?
      if line = @io.gets("\n", true)
        line
      else
        @state = State::Done
        nil
      end
    end

    def pack_data(string, data)
      string.chars.each_slice(8) do |chunk|
        data.write_byte(pack_8(chunk))
      end
    end

    def pack_8(data : Array(Char)) : UInt8
      pos = 0
      mask = 1u8 << 7
      out_data = 0u8
      data.each_with_index do |c|
        out_data |= mask if c != '.'
        mask >>= 1
      end
      out_data
    end
  end
end
