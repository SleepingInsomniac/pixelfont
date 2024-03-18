require "./font"

module Pixelfont
  # "\xACPIXF\n"
  MAGIC = Bytes[0xAC, 80, 73, 88, 70, 10]

  module Binary
    def self.write(io : IO, font : Font)
      io.write(MAGIC)
      io.write_byte(VERSION.bytesize.to_u8)
      io << VERSION
      io.write_bytes(font.properties.value, IO::ByteFormat::BigEndian)
      font.graphemes.each do |(char, glyph)|
        io << char
        io.write_bytes(glyph.width, IO::ByteFormat::BigEndian)
        io.write_bytes(glyph.height, IO::ByteFormat::BigEndian)

        trim_size = glyph.data.rindex { |byte| byte != 0 } || -1
        trimmed_data = glyph.data[..trim_size]

        io.write_byte(trimmed_data.size.to_u8)
        io.write(trimmed_data)
      end
    end

    def self.read(io : IO)
      magic = Bytes.new(6)
      io.read_fully(magic)
      raise "Magic mismatch" unless magic == MAGIC

      version_size = io.read_bytes(UInt8)
      version_bytes = Bytes.new(version_size)
      io.read_fully(version_bytes)
      version = String.new(version_bytes)
      properties = Properties.new(io.read_bytes(UInt32, IO::ByteFormat::BigEndian))

      graphemes = {} of Char => Grapheme

      while char = io.read_char
        width = io.read_bytes(UInt16, IO::ByteFormat::BigEndian)
        height = io.read_bytes(UInt16, IO::ByteFormat::BigEndian)
        size = io.read_bytes(UInt8)
        data = Bytes.new(size)
        io.read_fully(data)
        graphemes[char] = Grapheme.new(width, height, data)
      end

      Font.new(graphemes, properties)
    end
  end
end
