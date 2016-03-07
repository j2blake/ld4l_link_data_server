require 'rdf'
require 'rdf/json'
require 'rdf/raptor'
require 'rdf/rdfxml'
require 'zlib'
require 'tilt/erubis'

require 'linked_data_server/file_systems'
require 'linked_data_server/process_arguments'
require 'linked_data_server/paths'

module Kernel
  def bogus(message)
    puts(">>>>>>>>>>>>>BOGUS #{message}")
  end
end

module LinkedDataServer
  # You screwed up the calling sequence.
  class IllegalStateError < StandardError
  end

  # What did you ask for?
  class UserInputError < StandardError
  end
end
