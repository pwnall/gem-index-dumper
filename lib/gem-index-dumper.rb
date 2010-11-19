require 'digest/sha1'
require 'fileutils'
require 'tempfile'

require 'rubygems'
require 'bundler'

module GemIndexDumper
  def self.all_remote_gems
    Gem::SpecFetcher.new.list(true, true).values.first
  end
  
  def self.dump_remote_gems(pattern = nil)
    gems = all_remote_gems
    gems.sort!
    gems.map { |data| "#{data[0]} / #{data[2]}   v#{data[1].to_s}\n" }.join
  end
  
  def self.gem_digest(info)
    uri = Gem.sources.first
    spec = Bundler::RemoteSpecification.new(info[0], info[1], info[2], uri)
    gem_file = Tempfile.new 'gem'
    gem_path = gem_file.path
    gem_file.close true
    
    download_path = File.join(gem_path, 'cache')
    FileUtils.mkdir_p download_path
    gem_file = Gem::RemoteFetcher.fetcher.download(spec, uri, gem_path)
    digest = Digest::SHA1.hexdigest File.read(gem_file)
    FileUtils.rm_r gem_path
    digest
  end
  
  def self.dump_gem_digests(name_pattern, version_pattern = nil)
    gems = all_remote_gems.select { |data| name_pattern =~ data[0] }
    gems.sort!
    if version_pattern
      gems = gems.select { |data| version_pattern =~ data[1].to_s }
    else
      # Pick the most recent gems.      
      gems_by_name = {}
      gems.each { |data| gems_by_name[data[0]] = data }
      gems = gems_by_name.values
      gems.sort!
    end
    
    gems.map { |data|
      "#{data[0]} / #{data[2]}   v#{data[1].to_s}   = #{gem_digest(data)}\n"
    }.join
  end
end
