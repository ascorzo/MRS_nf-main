#!/usr/bin/python
import sys
import socket
from time import sleep

if len(sys.argv) != 3:
    print("Wrong arguments. Usage:\n start_client.py SERVER_IP PORT")
    exit()
print(sys.argv)

PORT = int(sys.argv[2])
SERVER = sys.argv[1]
ADDR = (SERVER, PORT)

# Initialize connection
client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client.connect(ADDR)
