-----------------------
1st thoughts
-----------------------

The process:
	Go through all URIs of the triple-store (subjects)
	For each one, 
		create a graph of all incoming and outgoing properties, types and labels of related objects.
		Write the graph to a file
	Ensure, do the report anyway

Go through the URIs
	Use a query with limit and offset
	
	Maintain the bookmark after each successful write.
		The bookmark holds the offset of the most recently written graph.
		Flush the bookmark to disk before each query, and when interrupted
		Clear the bookmark from disk on a normal exit.
		On startup, check the bookmark. If not there, or if RESTART is requested, zero it out.
		Where is the bookmark stored? In the pairtree?
		Serializing: http://www.sitepoint.com/choosing-right-serialization-format/
		
Create the graph to describe the URI
	How many queries to get incoming and outgoing, with types and labels of related objects?
	
Write the graph to a file
	Need pairtree or something like it.
	Write as n3? Probably most compact, but logically not straightforward. Does either of these matter?
	
Do the report
	Report stats must either accumulate over resumed runs, or explicitly apply only to a single run.
	Starting bookmark, ending bookmark, number of URIs processed this run.
	Average number of triples per graph
	OFFSET of last URI.
	Ran to completion, or interrupted?
	
Resources:
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
	
The server:
	Do we need to worry about the name of the file that is server, or does the browser worry about it?
	The server must add the doc-specific triples, if only because the name of the doc depends on the format
		Does this mean that no docs are served verbatim?
	
--------------------------
Structure
--------------------------

Usage: ld4s_link_data_generator 

Main class: Ld4lLds:LinkDataGenerator
	Processes the arguments
	Opens the triple-store (or checks that it is running)
	Resets the bookmark if appropriate.
	Opens the PairTree
	Loop while get_next_uri
		UriProcessor.new(ts, pairtree, uri).run
		Rescue Interrupt
		Rescue VenialError
	get_next_uri handles the bookmark the queries and the iteration through the results.

UriProcessor
	Issue the queries for the URI
	Build the graph
	Write it to PairTree.
	What sort of errors might be venial?
	