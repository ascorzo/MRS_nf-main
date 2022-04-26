#!/usr/bin/python3
#
#######################################################################
#Date: 16/11/2020
#By: julio.rodino@ug.uchile.cl
#######################################################################
#
##  Usage: nf_pipeline.py < exp_parameters.in
#
#######################################################################
## Note: input file should containt an answer to the questions in the
## question list
#######################################################################

import subprocess
import sys
import os.path
import socket
from time import sleep

script = os.path.basename(__file__)


#######################################################################
####################    NETWORKING	###################################
#######################################################################

##   PARAMETERS
HEADER = 64
PORT = 5050
FORMAT = 'utf-8'
DISCONNECT_MESSAGE = "!DISCONNECT"
SERVER = "192.168.1.120"
ADDR = (SERVER, PORT)

##  FUNCTION
def send(msg):
    message = msg.encode(FORMAT)
    msg_length = len(message)
    send_length = str(msg_length).encode(FORMAT)
    send_length += b' ' * (HEADER - len(send_length))
    client.send(send_length)
    client.send(message)
    print(client.recv(2048).decode(FORMAT))

## Initialize connection
client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client.connect(ADDR)

#######################################################################
####################    Get EXPERIMENT INFORMATION	###################
#######################################################################
answers = []

exp_inf = {}

questions = [
    "Name",
    "Date",
    "TR",
    "Total Trials",
    "Baseline Trials",
    "File_type",
    "Inp_dir"
]

answers = []

exp_inf = {}

#Ask for info
for question in questions:

    print(question)
    exp_inf[question] = input()

#Get path variables
(dirName, fileName) = os.path.split(exp_inf["Inp_dir"])
(fileBaseName, fileExtension)=os.path.splitext(fileName)

print(f"{dirName}, {fileName}, {fileBaseName}, {fileExtension}")

#######################################################################
####################	MAIN LOOP START		###########################
#######################################################################

trials = range(1,int(exp_inf["Total Trials"]))

for trial in trials:

    ima_file = f"{dirName}/{trial}.{exp_inf.get('File_type')}"
    ima_filename = f"{trial}.{exp_inf.get('File_type')}"

    # 1. Check if file exist or wait for it to appear
    while not os.path.isfile(ima_file):
        sleep(0.2)
        print(f"[{script}]: waiting for {ima_filename} to appear...")


    # 2.Create header and RAW file

    p1 = subprocess.run(f"./ima_mrs2raw_hdr -in {ima_file}",
        check = True,
        shell = True
        )

    # 3. Create Control File
    p2 = subprocess.run(f"./nf_lcm_create_control {ima_file}",
        check = True,
        shell = True
        )
    # 4. Execute lcmodel files
    p3_1 = subprocess.run(f"chmod +x {dirName}/{trial}.lcmodel",
        check = True,
        shell = True
        )
    p3_2 = subprocess.run(f"{dirName}/{trial}.lcmodel",
        check = True,
        shell = True
        )

    # 5. Create txt files from .table files
    p4 = subprocess.run(f"./lcm_table2txt_sv {dirName}/{trial}.table",
        check = True,
        shell = True
        )
    # 6. Send Glu value to feedback pc
    with open(f"{dirName}/{trial}.lc_out", mode= "r") as f:
        line = f.readline()
        f.close()
        metab = line.split("\t")
        glu = metab[14]
        glu_sd = metab[15]
        msg = f"Trial: {trial}; Glu = {glu}; SD = {glu_sd}"
        print(f"[{script}]: Sending message...")
        send(msg)

print("Session Completed.")

send(DISCONNECT_MESSAGE)

print("DONE. Disconecting...")
exit()


#############################################
##          TIMELINE
##17/11/2020: Input an ima file and out a lc_out file. COMPLETED
############
##17/11/2020: Socket protocol to be implemented. Script needs
############    to send glutamate value to feedback computer.
############    This corresponds to step 6.
##17/11/2020: Comunication with feedback computer completed. Not
############    yet tested. Next step is testing the sctipt.
##
##20/01/2021: nf_lcm_create_control Now is able to recive watter
#############   file. To use it in estimation ecc_on parameter 
#############   has to be added when creating file.
#############################################
##          ERRORS                      #####
##ERROR IN subprocess.run() FUNCTION. FIX NEEDED (SOLVED 17/11/2020)
##ERROR IN STEP 4 [EXECUTING LCMODEL FILE]. FIX NEEDED (SOLVED 17/11/2020)
##
##          BUSGS                       #####
##
##  IF inp_dir does not end in / then the last folder is deleted. (LOW priority)
##
##  Message for the feedback computer is hard coded to send glutamate values.
##  It should be specified in the input file to give the option of what
##  metabolite to use. (LOW PRIORITY)
##
##  All the networking is hard coded. It should be a parameter in the input file.
##  (Medium Priority)
##
##  Use of ecc and water file has to be hard coded. (Medium priority)
