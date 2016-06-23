#!/usr/local/bin/sage -python                   
import multiprocessing
import time
import BaseHTTPServer
from SocketServer import ThreadingMixIn
from BaseHTTPServer import HTTPServer, BaseHTTPRequestHandler
import threading

import sys
from sage.all import *
import urllib 
load('tool.sage')
local = "localhost"
web = 'paperman.cadilhac.name'

HOST_NAME = local    # !!!REMEMBER TO CHANGE THIS!!!
PORT_NUMBER = 8001 # Maybe set this to 9000.
date = time.asctime().replace(" ","").replace(":",".")
log = file("log/"+date,"w")

class MyHandler(BaseHTTPServer.BaseHTTPRequestHandler):
    def do_HEAD(s):
        s.send_response(200)
        s.send_header("Content-type", "text/html")
        s.end_headers()
    def do_GET(s):
        """Respond to a GET request."""
        s.send_response(200)
        s.send_header("Content-type", "text/html")
        s.end_headers()
        s.wfile.write(deal_request(s.path))
        print >>log, s.path
        log.flush()
class ThreadedHTTPServer(ThreadingMixIn, HTTPServer):
    """Handle requests in a separate thread."""        

if __name__ == '__main__':
    server_class = BaseHTTPServer.HTTPServer
    httpd =  ThreadedHTTPServer((HOST_NAME, PORT_NUMBER), MyHandler)
    print time.asctime(), "Server Starts - %s:%s" % (HOST_NAME, PORT_NUMBER)
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    httpd.server_close()
    print time.asctime(), "Server Stops - %s:%s" % (HOST_NAME, PORT_NUMBER)

