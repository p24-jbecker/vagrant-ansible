#!/usr/bin/env ruby

# Define deep_merge method for nested hashes
class ::Hash
  def deep_merge(second)
    merger = proc do |key, v1, v2|
      Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : Array === v1 && Array === v2 ? v1 | v2 : [:undefined, nil, :nil].include?(v2) ? v1 : v2
    end
    self.merge(second.to_h, &merger)
  end
end
