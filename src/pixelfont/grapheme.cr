module Pixelfont
  # A Bitmap for a character
  #
  # ```
  # .###.
  # #...#
  # #####
  # #...#
  # #...#
  # ```
  # becomes
  # `Bytes[0b01110_10001, 0b11111_10001, 0b10001_0000]`
  struct Grapheme
    property width : UInt16
    property height : UInt16
    property data : Bytes

    def initialize(@width, @height, @data)
    end
  end
end
