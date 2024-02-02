require "../spec_helper"

describe Pixelfont::Font do
  it "parses a font" do
    font = Pixelfont::Font.new("fonts/pixel-5x7")
    glyph = font.glyphs['A']
    glyph.bits.should eq(8386581866894852096u64)
    glyph.width.should eq(5u8)
    glyph.height.should eq(7u8)
  end

  it "displays a glyph" do
    font = Pixelfont::Font.new("fonts/pixel-5x7")
    string = "ABC"
    w = (5 * string.size) + (font.tracking * (string.size - 1))
    h = 7
    buffer = Array(Char).new(w * h) { ' ' }

    font.draw(string) do |x, y, on|
      buffer[y * w + x] = '█' if on
    end

    buffer.join.should eq(
      " ███  ████   ███ " \
      "█   █ █   █ █   █" \
      "█   █ █   █ █    " \
      "█   █ ████  █    " \
      "█████ █   █ █    " \
      "█   █ █   █ █   █" \
      "█   █ ████   ███ "
    )
  end
end
