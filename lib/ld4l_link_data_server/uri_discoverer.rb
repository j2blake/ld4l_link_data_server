=begin
--------------------------------------------------------------------------------

Repeatedly get bunches of URIs for Agents, Instances, and Works. Dispense them
one at a time.

The query should return the uris in ?uri, and should not contain an OFFSET or
LIMIT, since they will be added here.

Increments the offset in the bookmark, and periodically writes it to disk.
Clears it at the end.

--------------------------------------------------------------------------------
=end

module Ld4lLinkDataServer
  class UriDiscoverer
    QUERY_URIS = <<-END
      SELECT DISTINCT ?uri
      WHERE { 
        ?uri ?p ?o . 
      }
    END
    def initialize(ts, bookmark, limit)
      @ts = ts
      @limit = limit
      @bookmark = bookmark
      @uris = []
    end

    def each()
      while true
        if @uris.empty?
          @bookmark.persist
          replenish_buffer
        end
        return if @uris.empty?
        yield @uris.shift
        @bookmark.increment
      end
      @bookmark.clear
    end

    def replenish_buffer()
      @uris = find_uris("%s OFFSET %d LIMIT %d" % [QUERY_URIS, @bookmark.offset, @limit])
    end

    def find_uris(query)
      QueryRunner.new(query).execute(@ts).map { |r| r['uri'] }
    end

  end
end