import os
from flask import Flask, request, redirect, url_for, render_template, json
from optparse import OptionParser
import sys
sys.path.append( "lib/" )
from datetime import datetime
import urllib.parse
import urllib.request

''' Parser configuration '''
# adds a parser to enable command line port definition
parser = OptionParser( )
parser.add_option( "--port", type="int", dest="port", default="8070" )
( options, args ) = parser.parse_args( )

''' Flask configuration '''
# creates the app
app = Flask( 'cesar_ws' )

# sets the allowed file extensions, this enables security on server side
ALLOWED_EXTENSIONS = set( [ 'png', 'jpg', 'jpeg', 'gif' ] )

# sets the path to the default image folders
defaultimagepath = "static/images/"

# sets the OS path to the server
ospath = os.getcwd( ) + "/"

''' Flask Methods '''
# verifies if a file name is allowed to be uploaded
def allowed_file( filename ):
	return '.' in filename and filename.rsplit( '.', 1 )[ 1 ] in ALLOWED_EXTENSIONS

# renders the home page
@app.route ( '/', methods = [ 'GET' ] )
def home( ):
	return render_template( 'cesar.html' )

@app.route ( '/cesar', methods = [ 'POST' ] )
def cesar( ):
	data = request.get_json(force = True)

	key = int(data['key'])
	disc = {'a':chr(97+key),'b':chr(98+key),'c':chr(99+key),' ':' '}

	for i in range(97, 123):
	  n = i + key
	  if n > 122:
	    n -= 26
	  disc[chr(i)] = chr(n)

	text = data['code']
	
	output = ''
	for i in text:
	  output += disc[i]
	print (output)

	return output
			
if __name__ == "__main__":
	app.run( host='0.0.0.0', port=options.port, debug=True )
