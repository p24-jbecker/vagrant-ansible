#!/usr/bin/env ruby

def getInventoryPath(cfg)
  File.open(cfg, 'r') do |file|
    file.each_line do |line|
      if line.match(/inventory = (.*)/)
        result = line.split("=")
        return result[1].strip
      end
    end
  end
end
