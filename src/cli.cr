require "option_parser"
require "colorize"

require "./pixelfont"

USAGE = "Usage: pixelfont -f FONT_PATH [subcommand] [options]"

class Options
  property path : String? = nil
  property leading : Int8 = 1
  property tracking : Int8 = 1
  property fore : Char = '█'
  property back : Char = ' '
  property fixed_width = false
end

command : Symbol? = nil

options = Options.new

OptionParser.parse do |parser|
  parser.banner = USAGE
  parser.on("-v", "--version", "Show version") do
    puts "Pixelfont version #{Pixelfont::VERSION}\nhttps://github.com/SleepingInsomniac/pixelfont"
    exit(0)
  end
  parser.on("-f PATH", "--font=PATH", "Path to the font file") { |path| options.path = path }
  parser.on("-h", "--help", "Show this help") do
    puts parser
    exit
  end

  parser.on("display", "Display a message in the terminal") do
    command = :display

    parser.on("-l DIST", "--leading=DIST", "Space between lines") { |dist| options.leading = dist.to_i8 }
    parser.on("-t DIST", "--tracking=DIST", "Space between chars") { |dist| options.tracking = dist.to_i8 }
    parser.on("--fore=CHAR", "The foreground character") { |fore| options.fore = fore[0] }
    parser.on("--back=CHAR", "The background character") { |back| options.back = back[0] }
    parser.on("--fixed-width", "Each character is the same width") { options.fixed_width = true }
  end

  parser.on("export", "export a font to its 64 bit components") do
    command = :export
  end

  parser.invalid_option do |flag|
    STDERR.puts "ERROR: #{flag} is not a valid option."
    STDERR.puts parser
    exit(1)
  end
end

unless path = options.path
  STDERR.puts "Specify a font path:"
  STDERR.puts USAGE
  exit(1)
end

case command
when :display
  font = Pixelfont::Font.new(path)
  font.leading = options.leading
  font.tracking = options.tracking

  ARGV.each do |string|
    puts font.to_s(string, options.fore, options.back, fixed_width: options.fixed_width)
  end
when :export
  font = Pixelfont::Font.new(path)

  puts "# #{path}"
  puts "GRAPHEMES : Hash(Char, Tuple(UInt64, UInt8, UInt8)) = {"
  chars = font.graphemes.keys.sort
  chars.each do |char|
    g = font.graphemes[char]
    puts "  '#{char}' => Grapheme.new(#{g.width}_u16, #{g.height}_u16, Bytes[#{g.data.map { |d| "0x" + d.to_s(16) }.join(", ")}]),"
  end
  puts "}"
else
  STDERR.puts "Unknown command!"
end
