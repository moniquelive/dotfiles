# vim FTW
Pry.config.editor = "gvim --nofork"

class String
    def console_gray;         colorize(self, "\001\e[30m\002");  end
    def console_red;          colorize(self, "\001\e[1;31m\002");  end
    def console_dark_red;     colorize(self, "\001\e[31m\002");    end
    def console_green;        colorize(self, "\001\e[1;32m\002");  end
    def console_dark_green;   colorize(self, "\001\e[32m\002");    end
    def console_yellow;       colorize(self, "\001\e[1;33m\002");  end
    def console_dark_yellow;  colorize(self, "\001\e[33m\002");    end
    def console_blue;         colorize(self, "\001\e[1;34m\002");  end
    def console_dark_blue;    colorize(self, "\001\e[34m\002");    end
    def console_purple;       colorize(self, "\001\e[1;35m\002");  end

    def console_def;          colorize(self, "\001\e[1m\002");  end
    def console_bold;         colorize(self, "\001\e[1m\002");  end
    def console_blink;        colorize(self, "\001\e[5m\002");  end

    def colorize(text, color_code)  "#{color_code}#{text}\001\e[0m\002" end
end

# Prompt with ruby version
prompt = "".console_dark_red
prompt << "#{Rails.version}/" if defined?(Rails)
prompt << RUBY_VERSION
Pry.config.prompt = [
  proc { |obj, nest_level, _| "#{prompt} (#{obj}) > ".console_gray },
  proc { |obj, nest_level, _| "#{prompt} (#{obj}) * ".console_gray }
]

Pry.config.exception_handler = proc do |output,exception,_|
  output.puts "#{exception.class}: #{exception.message}".console_red
  output.puts "from #{exception.backtrace.first}".console_red
end

# Toys methods
# Stolen from https://gist.github.com/807492
class Array
  def self.toy(n=10, &block)
    block_given? ? Array.new(n,&block) : Array.new(n) {|i| i+1}
  end
end

class Hash
  def self.toy(n=10)
    # Hash[Array.toy(n).zip(Array.toy(n){|c| (96+(c+1)).chr})]
    {}.tap { |hsh| n.times {|i| hsh[('a'.ord+i).chr.to_sym] = i+1} }
  end
end

# loading rails configuration if it is running as a rails console
if defined?(Rails) && Rails.env
  #load File.join(ENV['HOME'], '.railsrc')

  # reload!
  require 'rails/console/app'
  extend Rails::ConsoleMethods
end

# Load plugins (only those I whitelist)

%w(awesome_print).each do |gem|
  require gem
end
AwesomePrint.pry!
