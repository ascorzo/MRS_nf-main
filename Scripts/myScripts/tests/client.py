#!/usr/bin/python3

import socket
from time import sleep


HEADER = 64
PORT = 5050
FORMAT = 'utf-8'
DISCONNECT_MESSAGE = "!DISCONNECT"
SERVER = "192.168.1.120"
ADDR = (SERVER, PORT)

def send(msg):
    message = msg.encode(FORMAT)
    msg_length = len(message)
    send_length = str(msg_length).encode(FORMAT)
    send_length += b' ' * (HEADER - len(send_length))
    client.send(send_length)
    client.send(message)
    print(client.recv(2048).decode(FORMAT))


# Initialize connection
client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client.connect(ADDR)


send("Hello World")
sleep(2)
for a in range(1,11):
    send(f"Trial:{a}")
    sleep(5)

send(DISCONNECT_MESSAGE)
