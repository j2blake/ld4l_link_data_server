get %r{^/(cornell|stanford|harvard)?$} do |univ|
  show_home_page(univ)
end

get '/termsOfUse' do
  'Check out the terms of use'
end

# Any request that doesn't start with a _, so __sinatra__500.png (for example) will pass through.
get /^\/[^_].*/ do
  tokens = parse_request
  #  logger.info ">>>>>>>PARSED #{tokens.inspect}"
  case tokens[:request_type]
  when :uri
    headers 'Vary' => 'Accept'
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
      'html' => 'text/html',
      'n3' => 'text/n3',
      'nt' => 'application/n-triples',
      'rdf' => 'application/rdf+xml',
      'rj' => 'application/rdf+json',
      'ttl' => 'text/turtle'
    }
  end

  def mime_to_ext
    ext_to_mime.invert
  end

  def void_prefixes
    {
      ''.to_sym => RDF::URI('http://draft.ld4l.org/') ,
      :dcterms => RDF::URI('http://purl.org/dc/terms/') ,
      :foaf => RDF::URI('http://xmlns.com/foaf/0.1/') ,
      :rdfs => RDF::URI('http://www.w3.org/2000/01/rdf-schema#') ,
      :void => RDF::URI('http://rdfs.org/ns/void#') ,
      :xsd => RDF::URI('http://www.w3.org/2001/XMLSchema#') ,
    }
  end

  def ld4l_prefixes
    {
      :annot => RDF::URI('http://www.w3.org/ns/oa#'),
      :dcterms => RDF::URI('http://purl.org/dc/terms/') ,
      :fast => RDF::URI('http://id.worldcat.org/fast/') ,
      :foaf => RDF::URI('http://xmlns.com/foaf/0.1/') ,
      :ld4lbib => RDF::URI('http://bib.ld4l.org/ontology/'),
      :ld4lcornell => RDF::URI('http://draft.ld4l.org/cornell/'),
      :ld4lharvard => RDF::URI('http://draft.ld4l.org/harvard/'),
      :ld4lstanford => RDF::URI('http://draft.ld4l.org/stanford/'),
      :locclass => RDF::URI('http://id.loc.gov/authorities/classification/'),
      :mads => RDF::URI('http://www.loc.gov/mads/rdf/v1#'),
      :owl => RDF::URI('http://www.w3.org/2002/07/owl#'),
      :oclc => RDF::URI('http://www.worldcat.org/oclc/'),
      :prov => RDF::URI('http://www.w3.org/ns/prov#'),
      :rdfs => RDF::URI('http://www.w3.org/2000/01/rdf-schema#') ,
      :skos => RDF::URI('http://www.w3.org/2004/02/skos/core#') ,
      :void => RDF::URI('http://rdfs.org/ns/void#'),
    }
  end

  def show_home_page(univ)
    graph = get_void_graph(univ)
    mime_ext = preferred_format('html')
    if mime_ext == 'html'
      merge_graph_into_home_page_template(univ, graph)
    else
      dump_graph(graph, mime_ext, void_prefixes)
    end
  end

  def get_void_graph(univ)
    filename = univ ? ("void_#{univ}.ttl") : "void.ttl"
    path = File.expand_path(filename, $files.path)
    graph = RDF::Graph.new
    graph.load(path)
    graph
  end

  def merge_graph_into_home_page_template(univ, graph)
    template = univ ? "dataset_#{univ}".to_sym : :dataset
    erb template, :locals => {:graph => graph.to_hash}
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
        return tokens.merge(:request_type => :uri, :format => preferred_format('ttl'))
      end
    else
      return tokens.merge(:request_type => :no_such_individual)
    end
  end

  # If request.preferred_type has no preference, it will prefer the first one.
  def preferred_format(default_ext)
    default_mime = ext_to_mime[default_ext]
    mime = request.preferred_type([default_mime] + mime_to_ext.keys)
    if mime && mime_to_ext.has_key?(mime)
      mime_to_ext[mime]
    else
      default_ext
    end
  end

  def known_individual(tokens)
    uri = tokens[:uri]
    if uri && $files.acceptable?(uri)
      $files.exist?(uri)
    else
      false
    end
  end

  def recognized_format(tokens)
    ext_to_mime.has_key?(tokens[:format])
  end

  def url_to_display(tokens)
    "%s/%s.%s" % tokens.values_at(:context, :localname, :format)
  end

  def display(tokens)
    path = $files.path_for(tokens[:uri])
    graph = RDF::Graph.new
    graph.load(path)
    graph << void_triples(tokens)
    dump_graph(graph, tokens[:format], ld4l_prefixes)
  end

  def void_triples(tokens)
    s = RDF::URI.new(tokens[:uri])
    p = RDF::URI.new("http://rdfs.org/ns/void#inDataset")
    o = RDF::URI.new($namespace + tokens[:context].chop)
    RDF::Statement(s, p, o)
  end

  def dump_graph(graph, format, prefixes)
    case format
    when 'n3', 'ttl'
      RDF::Raptor::Turtle::Writer.dump(graph, nil, :prefixes => prefixes)
    when 'nt'
      RDF::Raptor::NTriples::Writer.dump(graph)
    when 'rj'
      RDF::JSON::Writer.dump(graph, nil, :prefixes => prefixes)
    when 'html'
      '<pre>' + RDF::Raptor::Turtle::Writer.dump(graph, nil, :prefixes => prefixes).gsub('<', '&lt;').gsub('>', '&gt;') + '</pre>'
    else # 'rdf'
      RDF::RDFXML::Writer.dump(graph, nil, :prefixes => prefixes)
    end
  end

  def create_headers(tokens)
    {"Content-Type" => ext_to_mime[tokens[:format]] + ';charset=utf-8'}
  end

  def no_such_individual(tokens)
    "No such individual #{tokens[:uri]}"
  end

  def no_such_format(tokens)
    "No such format #{tokens[:format]}"
  end
end
