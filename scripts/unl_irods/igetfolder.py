#!/usr/bin/python

import sys, json
from isession import ISession

def main(argv):
    try:
        username = argv[0]
        password = argv[1]
        path = argv[2]
        local = argv[3]
        sess = ISession(username, password)
        sess.igetfolder(path, local)
        print('true')
    except Exception as e:
        pass

if __name__ == "__main__":
   main(sys.argv[1:])