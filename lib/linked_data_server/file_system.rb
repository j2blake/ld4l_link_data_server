module LinkedDataServer
  class FileSystem
    def initialize(root_dir, prefix)
      @root_dir = root_dir
      Dir.mkdir(@root_dir) unless Dir.exist?(@root_dir)

      @prefix = prefix
    end

    def path()
      @root_dir
    end

    def acceptable?(uri)
      uri.start_with?(@prefix)
    end

    def exist?(uri)
      begin
        File.exist?(path_for(uri))
      rescue
        raise "Failed a check for existence of '#{uri}': #{$!}\n    #{$!.backtrace.join('\n    ')}"
        false
      end
    end
    
    def exists?(uri)
      exist?(uri)
    end

    def path_for(uri)
      begin
        name = remove_prefix(uri)
        hash1, hash2 = hash_it(name)
        safe_name = encode(name)
        File.join(@root_dir, hash1, hash2, safe_name + '.ttl')
      rescue
        raise "Failed to build a path for '#{uri}': #{$!}\n    #{$!.backtrace.join('\n    ')}"
      end
    end

    def remove_prefix(uri)
      if uri.start_with?(@prefix)
        uri[@prefix.size..-1]
      else
        uri
      end
    end

    def hash_it(name)
      hash = Zlib.crc32(name).to_s(16)
      [hash[-4, 2], hash[-2, 2]]
    end

    ENCODE_REGEX = Regexp.compile("[\"*+,<=>?\\\\^|]|[^\x21-\x7e]", nil)

    def encode(name)
      name.gsub(ENCODE_REGEX) { |c| char2hex(c) }.tr('/:.', '=+,')
    end
  end
end
