#!/usr/bin/env ruby

require 'fileutils'

Dir.glob('config/*.sc') do |filename|
    dest = filename.gsub('.sc','.yml')
    FileUtils.cp(filename, dest)
end
