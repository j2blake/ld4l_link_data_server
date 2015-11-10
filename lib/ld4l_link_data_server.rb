$LOAD_PATH.unshift File.expand_path('../../../triple_store_drivers/lib', __FILE__)
$LOAD_PATH.unshift File.expand_path('../../../triple_store_controller/lib', __FILE__)
require 'triple_store_drivers'
require 'triple_store_controller'

require 'pairtree'
require 'rdf'

require "ld4l_link_data_server/bookmark"
require "ld4l_link_data_server/linked_data_creator"
require "ld4l_link_data_server/query_runner"
require "ld4l_link_data_server/report"
require "ld4l_link_data_server/uri_discoverer"
require "ld4l_link_data_server/uri_processor"
require "ld4l_link_data_server/version"

module Kernel
  def bogus(message)
    puts(">>>>>>>>>>>>>BOGUS #{message}")
  end
end

module Ld4lLinkDataServer
  # You screwed up the calling sequence.
  class IllegalStateError < StandardError
  end

  # What did you ask for?
  class UserInputError < StandardError
  end
end
