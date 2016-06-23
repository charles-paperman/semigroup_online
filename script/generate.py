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


if __name__ == '__main__':
    building_data()
