module Pixelfont
  # A glyph is a character reduced to the bits required to represent it.
  # For instance, a 5x5 'A' Glyph
  # ```
  # .###.
  # #...#
  # #####
  # #...#
  # #...#
  # ```
  # becomes
  # `0b01110_10001_11111_10001_10001_u64`
  struct Glyph
    property bits : UInt64
    property width : UInt8
    property height : UInt8

    def initialize(@bits, @width, @height)
    end
  end
end
