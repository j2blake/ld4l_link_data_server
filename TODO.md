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

