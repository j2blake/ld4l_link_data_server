get '/' do
  'This is the home page. Describe what they should have done instead. <a href="./termsOfUse">Try the terms of use<a>'
end

get '/termsOfUse' do
  'Check out the terms of use'
end

get '/*' do
  request_type, localname, format = parse_request
  case request_type
  when :uri
    redirect url_to_display(localname, format), 303
  when :display_url
    [200, create_headers(format), display(localname, format)]
  when :no_such_individual
    [404, no_such_individual(localname)]
  when :no_such_format
    [404, no_such_format(format)]
  else
    [404, "BAD REQUEST: #{request.path}, type=#{request_type}, localname=#{localname}, format=#{format}"]
  end
end

helpers do
  def ext_to_mime
    {
      'rdf' => 'application/rdf+xml',
      'nt' => 'application/n-triples',
      'ttl' => 'text/turtle',
      'n3' => 'text/n3',
      'rj' => 'application/rdf+json'
    }
  end

  def mime_to_ext
    ext_to_mime.invert
  end

  def parse_request
    if request.path =~ %r{^/([^/]+)/\1\.(\w+)$} # /localname/localname.format
      localname = $1
      format = $2
      return [:no_such_individual, localname, format] unless known_individual(localname)
      return [:no_such_format, localname, format] unless recognized_format(format)
      [:display_url, localname, format]
    elsif request.path =~ %r{^/([^/]+)$} # No internal slash
      localname = $1
      format = test_accept_header
      return [:no_such_individual, localname, format] unless known_individual(localname)
      return [:no_such_format, localname, format] unless recognized_format(format)
      [:uri, localname, format]
    else
      [:garbage, "", ""]
    end
  end

  def test_accept_header
    mime = request.preferred_type(mime_to_ext.keys)
    if mime && mime_to_ext.has_key?(mime)
      mime_to_ext[mime]
    else
      'rdf'
    end
  end

  def known_individual(localname)
    $files.exists?('http://ld4l.harvard.edu/' + localname)
  end

  def recognized_format(format)
    ext_to_mime.has_key?(format)
  end

  def url_to_display(localname, format)
    "/%s/%s.%s" % [localname, localname, format]
  end

  def display(localname, format)
    uri = "http://ld4l.harvard.edu/" + localname

    path = File.expand_path('linked_data.ttl', $files.path_for(uri))
    @graph = RDF::Graph.new
    @graph.load(path)

    case format
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

  def create_headers(format)
    {"Content-Type" => ext_to_mime[format]}
  end

  def no_such_individual(localname)
    "No such individual #{localname}"
  end

  def no_such_format(format)
    "No such format #{format}"
  end
end
