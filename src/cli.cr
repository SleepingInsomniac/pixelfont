require "option_parser"
require "colorize"

require "./pixelfont"
require "./pixelfont/binary"

USAGE = "Usage: pixelfont -f FONT_PATH [subcommand] [options]"

enum Format
  Text
  Binary
end

class FileOptions
  property path : String? = nil
  property format : Format = Format::Text
end

struct DisplayOptions
  property leading : Int8 = 1
  property tracking : Int8 = 1
  property fore : Char = '█'
  property back : Char = ' '
  property fixed_width = false
end

command : Symbol? = nil

input_options = FileOptions.new
output_options = FileOptions.new
display_options = DisplayOptions.new

OptionParser.parse do |parser|
  parser.banner = USAGE

  parser.on("-v", "--version", "Show version") do
    puts "Pixelfont version #{Pixelfont::VERSION}\nhttps://github.com/SleepingInsomniac/pixelfont"
    exit(0)
  end

  parser.on("-h", "--help", "Show this help") do
    puts parser
    exit
  end

  parser.on("-i PATH", "--input=PATH", "Path to the font file") { |path| input_options.path = path }

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  parser.on("display", "Display a message in the terminal") do
    command = :display

    parser.on("-l DIST", "--leading=DIST", "Space between lines") { |dist| display_options.leading = dist.to_i8 }
    parser.on("-t DIST", "--tracking=DIST", "Space between chars") { |dist| display_options.tracking = dist.to_i8 }
    parser.on("--fore=CHAR", "The foreground character") { |fore| display_options.fore = fore[0] }
    parser.on("--back=CHAR", "The background character") { |back| display_options.back = back[0] }
    parser.on("--fixed-width", "Each character is the same width") { display_options.fixed_width = true }
  end

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  parser.on("export", "export a font to its 64 bit components") do
    command = :export

    parser.on("-f FORMAT", "--format FORMAT", "Output format") { |f| output_options.format = Format.parse(f) }
    parser.on("-o PATH", "--output PATH", "Output path") { |out_path| output_options.path = out_path }
  end

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  parser.on("embed", "Display the code to embed a font") do
    command = :embed
  end

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  parser.invalid_option do |flag|
    STDERR.puts "ERROR: #{flag} is not a valid option."
    STDERR.puts parser
    exit(1)
  end
end

unless path = input_options.path
  STDERR.puts "Specify a font path:"
  STDERR.puts USAGE
  exit(1)
end

font = case File.extname(path)
       when ".txt" then Pixelfont::Font.new(path)
       else
         File.open(path, "rb") { |f| Pixelfont::Binary.read(f) }
       end

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

case command
when :display
  font.leading = display_options.leading
  font.tracking = display_options.tracking

  ARGV.each do |string|
    puts font.to_s(string, display_options.fore, display_options.back, fixed_width: display_options.fixed_width)
  end
when :export
  case output_options.format
  when Format::Binary
    output_options.path.try do |path|
      File.open(path, "wb") do |f|
        Pixelfont::Binary.write(f, font)
      end
    end
  when Format::Text
    out_io = if output_path = output_options.path
               File.open(output_path, "w")
             else
               STDOUT
             end

    font.properties.each do |prop|
      out_io.puts ":#{prop}"
    end

    font.graphemes.keys.sort.each do |char|
      if char == ' ' || char == '.'
        out_io.puts "'#{char}'"
      else
        out_io.puts char
      end

      out_io.puts font.to_s(char.to_s, fore: '█', back: '.')
      out_io.puts
    end

    out_io.close unless out_io == STDOUT
  end
when :embed
  data = IO::Memory.new
  Pixelfont::Binary.write(data, font)
  puts data.to_slice.each_slice(32).map(&.join(",")).join(",\n")
else
  STDERR.puts "Unknown command!"
end
