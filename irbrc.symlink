## Add all gems in the global gemset to the $LOAD_PATH so they can be used in rails3 console with bundler
#if defined?(::Bundler)
#  $LOAD_PATH.concat Dir.glob("#{ENV['rvm_path']}/gems/#{ENV['rvm_ruby_string']}@global/**/lib")
#end
#
#%w{rubygems awesome_print wirble}.each do |lib|
#    begin
#        require lib
#    rescue LoadError => err
#        $stderr.puts "Couldn't load #{lib}: #{err}"
#    end
#end
#%w{init colorize}.each { |str| Wirble.send(str) }
#
#def dir(t)
#  t.public_methods(false).sort
#  #(t.public_methods - Object.instance_methods).sort
#end

def log_to(stream=STDOUT, colorize=true)
    #ActiveRecord::Base.colorize_logging = colorize
    ActiveRecord::Base.logger = Logger.new(stream)
    ActiveRecord::Base.clear_active_connections!
end

# copied from pry-everywhere: http://lucapette.com/pry/pry-everywhere/
#
# https://github.com/carlhuda/bundler/issues/183#issuecomment-1149953

if defined?(::Bundler)
  global_gemset = ENV['GEM_PATH'].split(':').grep(/ruby.*@global/).first
  if global_gemset
    all_global_gem_paths = Dir.glob("#{global_gemset}/gems/*")
    all_global_gem_paths.each do |p|
      gem_path = "#{p}/lib"
      $LOAD_PATH << gem_path
    end
  end
end

# # Use Pry everywhere
# require "rubygems"
# require 'pry'
# Pry.start
# exit

