import sys, os, pygame, time, struct
import serial

from pygame.locals import *

pygame.init()
screen = pygame.display.set_mode((696, 396))
pygame.display.set_caption('Pygame Caption')
pygame.mouse.set_visible(0)
ser = serial.Serial('/dev/ttyUSB0',1200)

send=0
up = False
down = False
left =  False
right = False

def input(events):
	global send
	global down
	global left
	global right
	global up
	for event in events:
		#print event
		
		if event.type == QUIT:
			sys.exit(0)
		
		if event.type == KEYDOWN:
		  if event.key == K_LEFT:
		    left = True
		  if event.key == K_RIGHT:
		    right = True
		  if event.key == K_UP:
		    up = True
		  if event.key == K_DOWN:
		    down = True
		    
		if event.type == KEYUP:	  
		  if event.key == K_LEFT:
		    left = False
		  if event.key == K_RIGHT:
		    right = False
		  if event.key == K_UP:
		    up = False
		  if event.key == K_DOWN:
		    down = False

while True:
	send=0
	input( pygame.event.get() )
	if up:
	  send |= 1
	if down:
	  send |= (1<<1)
	if left:
	  send |= (1<<2)
	if right:
	  send |= (1<<3)
 
	#print send
	
	xorsend= send ^ 0x56; 
		
	ser.write(chr(0x00)+chr(0xFF)+chr(0x00)+chr(0xFF)+chr(0x00))
	ser.write(chr(0x46)+chr(0x67)+chr(0x50)+chr(send)+chr(xorsend))
	
	#print send
	#print xorsend
	
	time.sleep(0.1)
