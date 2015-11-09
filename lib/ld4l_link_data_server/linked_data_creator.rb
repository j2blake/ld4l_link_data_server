=begin rdoc
--------------------------------------------------------------------------------

Generate files of Linked Open Data from the triple-store, for the LOD server.
The files are created in a PairTree directory, in N3 format. When servicing a
request, the server will read the file into a graph, add document triples, and
serialize it to the requested format.

--------------------------------------------------------------------------------

Usage: ld4l_create_lod_files <target_dir> [RESTART] <report_file> [REPLACE]

--------------------------------------------------------------------------------
=end

module Ld4lLinkDataServer
  class LinkedDataCreator
    USAGE_TEXT = "Usage: ld4l_create_lod_files <target_dir> [RESTART] <report_file> [REPLACE]"
    def process_arguments(args)
      @restart = args.delete('RESTART')
      replace_report = args.delete('REPLACE')

      raise UserInputError.new(USAGE_TEXT) unless args && args.size == 2

      @pair_tree_base = File.expand_path(args[0])

      raise UserInputError.new("#{args[1]} already exists -- specify REPLACE") if File.exist?(args[0]) unless replace_report
      raise UserInputError.new("Can't create #{args[1]}: no parent directory.") unless Dir.exist?(File.dirname(args[1]))
      @report = Report.new(File.expand_path(args[1]))
    end

    def connect_triple_store
      selected = TripleStoreController::Selector.selected
      raise UserInputError.new("No triple store selected.") unless selected

      TripleStoreDrivers.select(selected)
      @ts = TripleStoreDrivers.selected

      raise IllegalStateError.new("#{@ts} is not running") unless @ts.running?
      logit("Connected to triple-store: #{@ts}")
    end

    def connect_pairtree
      @files = Pairtree.at(@pair_tree_base, :create => true)
      logit("Connected to pairtree at #{@pair_tree_base}")
    end

    def initialize_bookmark
      @bookmark = Bookmark.new(@files, @restart)
    end

    def iterate_through_uris
      uris = UriDiscoverer.new(@ts, @bookmark, 1000) 
      begin
        puts "Beginning processing. Press ^c to interrupt."
        uris.each do |uri|
          UriProcessor.new(@ts, @files, @report, uri).run
        end
        @report.summarize(@bookmark, :complete)
      rescue Interrupt
        @bookmark.persist
        @report.summarize(@bookmark, :interrupted)
      end
      logit("Complete")
    end

    def report
      bogus "report"
    end

    def logit(message)
      m = "#{Time.new.strftime('%Y-%m-%d %H:%M:%S')} #{message}"
      puts m
      @report.puts(m)
    end

    def run
      begin
        process_arguments(ARGV)

        begin
          connect_triple_store
          connect_pairtree
          initialize_bookmark

          iterate_through_uris
          report
        ensure
          @report.close if @report
        end
      rescue UserInputError, IllegalStateError
        puts
        puts "ERROR: #{$!}"
        puts
      end
    end
  end
end

=begin
Loop while get_next_uri
  UriProcessor.new(ts, pairtree, uri).run
  Rescue Interrupt
  Rescue VenialError
get_next_uri handles the bookmark the queries and the iteration through the results.
=end