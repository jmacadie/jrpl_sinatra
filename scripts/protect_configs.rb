#!/usr/bin/env ruby

require 'fileutils'
require 'tempfile'

Dir.glob('config/*.yml') do |filename|
    dest = filename.gsub('.yml','.sc')
    FileUtils.cp_r(filename, dest)
    tmp = Tempfile.new('tmp.yml')
    File.open(filename, 'r') do |file|
        file.each_line do |line|
            if line.include? ':'
                tmp.puts line.split(':')[0].to_s + ':'
            else
                tmp.puts line
            end
        end
    end 
    FileUtils.mv(tmp.path, filename)
end