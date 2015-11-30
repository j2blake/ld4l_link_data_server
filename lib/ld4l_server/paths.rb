get '/' do
  'This is the home page. Describe what they should have done instead. <a href="./termsOfUse">Try the terms of use<a>'
end

get '/termsOfUse' do
  'Check out the terms of use'
end

get '/*' do
  tokens = parse_request
#  logger.info ">>>>>>>PARSED #{tokens.inspect}"
  case tokens[:request_type]
  when :uri
    redirect url_to_display(tokens), 303
  when :display_url
    [200, create_headers(tokens), display(tokens)]
  when :no_such_individual
    [404, no_such_individual(tokens)]
  when :no_such_format
    [404, no_such_format(tokens)]
  else
    [404, "BAD REQUEST: #{request.path} ==> #{tokens.inspect}"]
  end
end

helpers do
  def ext_to_mime
    {
      'ttl' => 'text/turtle',
      'n3' => 'text/n3',
      'nt' => 'application/n-triples',
      'rdf' => 'application/rdf+xml',
      'rj' => 'application/rdf+json'
    }
  end

  def mime_to_ext
    ext_to_mime.invert
  end

  def parse_request
    if request.path =~ %r{^/([^/]+/)?([^/]+)\.(\w+)$} # /context/localname.format
      tokens = {:context => $1, :localname => $2, :format => $3}
    elsif request.path =~ %r{^/([^/]+/)?([^/]+)$} # /context/localname
      tokens = {:context => $1, :localname => $2}
    else
      tokens = {:localname => request.path.sub(%r{^/}, '')}
    end

    tokens[:uri] = "%s%s%s" % [$namespace, tokens[:context], tokens[:localname]]

    if known_individual(tokens)
      if tokens[:format]
        if recognized_format(tokens)
          return tokens.merge(:request_type => :display_url)
        else
          return tokens.merge(:request_type => :no_such_format)
        end
      else
        return tokens.merge(:request_type => :uri, :format => test_accept_header)
      end
    else
      return tokens.merge(:request_type => :no_such_individual)
    end
  end

  def test_accept_header
    mime = request.preferred_type(mime_to_ext.keys)
    if mime && mime_to_ext.has_key?(mime)
      mime_to_ext[mime]
    else
      'ttl'
    end
  end

  def known_individual(tokens)
    $files.exists?(tokens[:uri])
  end

  def recognized_format(tokens)
    ext_to_mime.has_key?(tokens[:format])
  end

  def url_to_display(tokens)
    "%s/%s.%s" % tokens.values_at(:context, :localname, :format)
  end

  def display(tokens)
    path = File.expand_path('linked_data.ttl', $files.path_for(tokens[:uri]))
    @graph = RDF::Graph.new
    @graph.load(path)

    case tokens[:format]
    when 'n3', 'ttl'
      RDF::Raptor::Turtle::Writer.dump(@graph)
    when 'nt'
      RDF::Raptor::NTriples::Writer.dump(@graph)
    when 'rj'
      RDF::JSON::Writer.dump(@graph)
    else # 'rdf'
      RDF::RDFXML::Writer.dump(@graph)
    end
  end

  def create_headers(tokens)
    {"Content-Type" => ext_to_mime[tokens[:format]]}
  end

  def no_such_individual(tokens)
    "No such individual #{tokens[:uri]}"
  end

  def no_such_format(tokens)
    "No such format #{tokens[:format]}"
  end
end
