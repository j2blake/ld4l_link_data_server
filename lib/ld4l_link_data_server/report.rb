=begin
--------------------------------------------------------------------------------

Write the report to a file, and to the console.
Repeatedly get bunches of URIs for Agents, Instances, and Works. Dispense them
one at a time.

The query should return the uris in ?uri, and should not contain an OFFSET or
LIMIT, since they will be added here.

Increments the offset in the bookmark, and periodically writes it to disk.
Clears it at the end.

--------------------------------------------------------------------------------
=end

module Ld4lLinkDataServer
  class Report
    def initialize(path)
      @file = File.open(path, 'w')
    end

    def logit(message)
      m = "#{Time.new.strftime('%Y-%m-%d %H:%M:%S')} #{message}"
      puts m
      @file.puts m
    end

    def record
      #  Something that the URI processor will do.
    end

    def summarize(bookmark, status)
      first = bookmark.start_offset
      last = bookmark.offset
      how_many = last - first
      if status == :complete
        logit("Generated for URIs from offset %d to %d: processed %d URIs." % [first, last, how_many])
      else
        logit("Interrupted with offset %d -- started at %d: processed %d URIs." % [last, first, how_many])
      end
    end

    def close()
      @file.close if @file
    end
  end
end
