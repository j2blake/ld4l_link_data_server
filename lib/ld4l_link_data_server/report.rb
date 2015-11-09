def initialize(path)
end

def puts
end

def record
  #  Something that the URI processor will do.
end

def summarize
  logit("Generated for URIs from offset %d to %d: processed %d URIs." % [start_offset, @bookmark.offset, @bookmark.offset - start_offset])
  logit("Interrupted with offset %d -- started at %d: processed %d URIs." % [@bookmark.offset, start_offset, @bookmark.offset - start_offset])
end

def close
end
