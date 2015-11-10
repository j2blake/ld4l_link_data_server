=begin
--------------------------------------------------------------------------------

Process one URI, fetching the relevant triples from the triple-store, recording
stats, and writing an N3 file.

--------------------------------------------------------------------------------
=end

module Ld4lLinkDataServer
  class UriProcessor
    QUERY_OUTGOING_PROPERTIES = <<-END
    CONSTRUCT {
      ?uri ?p ?o
    }
    WHERE { 
      ?uri ?p ?o . 
    } LIMIT 10
    END
    def initialize(ts, files, report, uri)
      @ts = ts
      @files = files
      @report = report
      @uri = uri
    end

    def run()
      @graph = RDF::Graph.new
      @graph << QueryRunner.new(QUERY_OUTGOING_PROPERTIES).bind_uri('uri', @uri).construct(@ts)
    end
  end
end

=begin
UriProcessor
  Issue the queries for the URI
  Build the graph
  Write it to PairTree.
  What sort of errors might be venial?
=end