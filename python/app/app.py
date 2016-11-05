import os
from flask import Flask, request, redirect, url_for, render_template, json
from optparse import OptionParser
import sys
sys.path.append( "lib/" )
from datetime import datetime
import urllib.parse
import urllib.request

import pipes
from multiprocessing import Process

global numLines	# Counter of the number off lines read
global valor

'''CONSTANTS'''
BUFFER_SIZE = 1024					# Size of the message
LOGTEXT 	= '/tmp/gsep-boot-log'	# Path to the log text file
INPUTFILE 	= '/tmp/gsep-pipe-in'	# Path to the input text file
BLOCKSIZE 	= 50					# Size of the block (lines) that will be send each time

numLines = 0
valor	 = 0

''' Parser configuration '''
# adds a parser to enable command line port definition
parser = OptionParser( )
parser.add_option( "--port", type="int", dest="port", default="8070" )
( options, args ) = parser.parse_args( )

''' Flask configuration '''
# creates the app
app = Flask( 'sss' )
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


@app.route ( '/', methods = [ 'GET' ] )
def home1( ):
	print('hello')
	return render_template( 'cesar.html' )

@app.route ( '/cesar', methods = [ 'POST' ] )
def cesar( ):
	#print('hello cesar!')
	data = request.get_json(force = True)
	#print('fuck cesar!')


	order = int(data['order'])
	disc = {'a':chr(97+order),'b':chr(98+order),'c':chr(99+order),' ':' '}

	for i in range(97, 123):
	  n = i + order
	  if n > 122:
	    n -= 26
	  disc[chr(i)] = chr(n)

	#text = 'abc abc z function ord would get the int value of the char nd in case you want to convert back after playing with the number function chr does the trick'
	text = data['cifra']
	
	output = ''
	for i in text:
	  #print (disc[i])
	  output += disc[i]
	print (output)

	#print (json.dumps(data, indent=4, sort_keys=True))
	#return "CESAR RESPONSE"
	return output


@app.route ('/result', methods = [ 'POST' ])
def resultPost ( ):
	data = request.get_json(force = True)	

	print (json.dumps(data, indent=4, sort_keys=True))
	return "POST RESPONSE"

@app.route ('/result', methods = [ 'GET' ])
def resultGet ( ):
	return "GET"

# renders the home page
@app.route( '/home', methods = [ 'GET' ] )
def home( ):
	return render_template( 'homepage.html' )


@app.route( '/tcpclient', methods=[ 'POST' ] )
def tcpclient( ):

	post = request.form[ 'cmd' ];

	if( post != '' ):
		file = open( INPUTFILE, 'w' )
		file.write( post + '\n' )
		file.close( )

	return post
	
# Send simulator logtext to the UI
@app.route( '/textlog', methods=[ 'POST' ] )
def textlog( ):

	global numLines
	response = ''
	flag = 'False'
	flag = request.form[ 'flag' ]

	if flag == 'True':
		file = open( LOGTEXT, 'r' )	

		for i in range ( 0, numLines ):
			file.readline( )

		for i in range ( 0, BLOCKSIZE ):
			status = str( file.closed )
			if status is 'False':
				log = file.readline( )
				if log != '':
					numLines += 1
					response = response + '<div>' + log
				else:
					break
			else:
				break
		file.close( )
	
	return response

			
if __name__ == "__main__":
	app.run( host='0.0.0.0', port=options.port, debug=True )


