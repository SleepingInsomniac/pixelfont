require "./grapheme"

module Pixelfont
  class Parser
    enum State
      Reset
      ReadProperty
      ReadChar
      ReadData
      Finished
      Done
    end

    @state = State::Reset
    @io : IO

    @properties : Properties = Properties::None
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
        when .reset?         then reset
        when .read_property? then read_property
        when .read_char?     then read_char
        when .read_data?     then read_data
        when .finished?
          store_grapheme
          @state = State::Done
        end
      end

      {@properties, @graphemes}
    end

    def reset
      @current.width = 0
      @current.height = 0
      @string = ""
      @data.clear
      @state = State::ReadProperty
    end

    def read_property
      pos = @io.pos
      read_line.try do |line|
        if line =~ /:[A-Z][A-Za-z]{2,}/
          @properties |= Properties.parse(line[1..])
        else
          @io.pos = pos
          @state = State::ReadChar
        end
      end
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
        @state = State::Finished
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
