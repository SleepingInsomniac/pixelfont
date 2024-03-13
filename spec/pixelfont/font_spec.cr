require "../spec_helper"

describe Pixelfont::Font do
  it "parses a font" do
    font = Pixelfont::Font.new("fonts/pixel-5x7")
    g = font.graphemes['A']
    g.data.should eq(Bytes[116, 99, 31, 198, 32])
    g.width.should eq(5u16)
    g.height.should eq(7u16)
  end

  it "displays a string" do
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
