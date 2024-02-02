require "option_parser"
require "./pixelfont"

class Options
  property path : String? = nil
  property leading : Int8 = 1
  property tracking : Int8 = 1
  property fore : Char = '█'
  property back : Char = ' '
end

command = :display

options = Options.new

OptionParser.parse do |parser|
  parser.banner = "Usage: pixelfont STRING -f PATH [options]"
  parser.on("-v", "--version", "Show version") do
    puts "Pixelfont version #{Pixelfont::VERSION}\nhttps://github.com/SleepingInsomniac/pixelfont"
    exit(0)
  end
  parser.on("-f PATH", "--font=PATH", "Path to the font file") { |path| options.path = path }
  parser.on("-l DIST", "--leading=DIST", "Space between lines") { |dist| options.leading = dist.to_i8 }
  parser.on("-l DIST", "--tracking=DIST", "Space between glyphs") { |dist| options.leading = dist.to_i8 }
  parser.on("--fore=CHAR", "The foreground character") { |fore| options.fore = fore[0] }
  parser.on("--back=CHAR", "The background character") { |back| options.back = back[0] }
  parser.on("-h", "--help", "Show this help") do
    puts parser
    exit
  end

  parser.invalid_option do |flag|
    STDERR.puts "ERROR: #{flag} is not a valid option."
    STDERR.puts parser
    exit(1)
  end
end

case command
when :display
  if path = options.path
    font = Pixelfont::Font.new(path)
    font.leading = options.leading
    font.tracking = options.tracking

    ARGV.each do |string|
      puts font.to_s(string, options.fore, options.back)
    end
  else
    STDERR.puts "Specify a font path:"
    STDERR.puts "Usage: pixelfont STRING -f PATH [options]\n" \
                "                        ~~~~~~~"
  end
else
  STDERR.puts "Unknown command!"
end
