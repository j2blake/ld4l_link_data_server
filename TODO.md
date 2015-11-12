-----------------------
Resources
-----------------------

capturing control-c:
	http://stackoverflow.com/questions/2089421/capturing-ctrl-c-in-ruby
	begin
	  do stuff
	  clear bookmark
	rescue Interrupt
	  write bookmark
	  fall through (with notation)
	end
	print report
pairtree
	http://www.rubydoc.info/gems/pairtree/0.1.0/
	What should the filenames be? Does it matter?
sinatra
	http://www.sinatrarb.com/intro.html
	http://www.kalzumeus.com/2010/01/15/deploying-sinatra-on-ubuntu-in-which-i-employ-a-secretary/
serializing: 
	http://www.sitepoint.com/choosing-right-serialization-format/
content negotiation:
	http://www.w3.org/TR/swbp-vocab-pub/#recipe3
	
--------------------------
The server:
--------------------------

Responses:
	Home page:
		something helpful and descriptive
	termsOfUse:
		describe the license
	URI:
		If the individual exists, look at the accept header, and forward appropriately.
			default is rdf/xml
		Otherwise, 404 with an informative message.
	URI/localname.*
		If the type is not supported, 404 with an informative message
		If the URI can't be determined, 404 with an informative message
		If the individual doesn't exist, 404 with an informative message
	Other
		404 with an informative message
	
Do we honor a request for HTML? What should we show?
Do we need to worry about the name of the file that is served, or does the browser worry about it?
	appending /localname.type means that this will be used as the filename, in most browsers.
The server must add the doc-specific triples, if only because the name of the doc depends on the format
	get the URI of the doc from the file properties
	get the label from the label of the subject (default to something if no label)
	get the date from the file properties
	publisher is the base of the URI
	rights points to termsOfUse page.
	
	
--------------------------
Document info
--------------------------

http://wifo5-03.informatik.uni-mannheim.de/bizer/pub/LinkedDataTutorial/#deref

<http://vivo.cornell.edu/individual/CRW-dre39/CRW-dre39.n3>
        a           foaf:Document ;
        rdfs:label  "RDF description of Egerton, D - http://vivo.cornell.edu/individual/CRW-dre39" ;
        dc:date     "2015-11-11T11:23:40"^^xsd:dateTime ;
        dc:publisher <http://vivo.cornell.edu> ;
        dc:rights    <http://vivo.cornell.edu/termsOfUse> .

--------------------------
Still to do
--------------------------

More appropriate queries: titles as well as labels, etc.
	Look to the indexer for these?
	Apply different queries to different classes of object?

-------------------------
Multiple namespaces
-------------------------

The final namespaces will be something like:
  http://draft.ld4l.org/cornell/
  http://draft.ld4l.org/harvard/
  http://draft.ld4l.org/stanford/
  
Three instances of the app, three pairtree systems, pass args on startup
	Pairtree: prefix is http://draft.ld4l.org/cornell/, so only the localname
In config.ru:
	run AwesomeApp.new(app, bootstrap: true)
	http://stackoverflow.com/questions/9657202/pass-arguments-to-new-sinatra-app
	
	map('/example') { run ExampleController }
    map('/') { run ApplicationController }
    https://www.safaribooksonline.com/library/view/sinatra-up-and/9781449306847/ch04.html
    
But then how do we create the three pairtree systems?

Maybe one pairtree, prefix is http://draft.ld4l.org/ and the app uses a parameter to know its context path

The nice thing about three apps is that we can still redirect based on localname
	(can we? Or do we need an absolute redirect mechanism?)
	Needs to be absolute but we can do that.
	
-----------
So, in summary
-----------
The prefix approach
	Generator works as now, but with a required prefix as an argument. Only generates files for URIs that use the prefix
		Give it http://draft.ld4l.org/, and it will take it from there:
		Point out: this is not a namespace, this is a prefix.
	One pairtree, with paths that look like: co/rn/el/l-/00/00/...
	App can determine context from  URI, but should it have to?
The namespace approach:
	Generator works with namespace as an argument. 
		Must be run three times with three different namespaces to create three pairtrees
			paths look like 00/00/...
	Three apps serving the three pairtrees.
		How do we do redirects? We still get the full URL
Mix and match:
	Generator works with the prefix approach.
	3 servers with the namespace approach.
		
