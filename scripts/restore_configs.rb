#!/usr/bin/env ruby

require 'fileutils'

Dir.glob('config/*.yml') do |filename|
    FileUtils.rm filename, :force => true
end

Dir.glob('config/*.sc') do |filename|
    dest = filename.gsub('.sc','.yml')
    FileUtils.mv(filename, dest)
end