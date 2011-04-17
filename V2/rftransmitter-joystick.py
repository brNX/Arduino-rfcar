import sys, os, pygame, time, struct
import serial

from pygame.locals import *

pygame.init()
screen = pygame.display.set_mode((696, 396))
pygame.display.set_caption('Pygame Caption')
pygame.mouse.set_visible(0)
print pygame.joystick.get_count()
j=pygame.joystick.Joystick(0)
j.init()
ser = serial.Serial('/dev/ttyUSB0',1200)

#Check init status 
if j.get_init() == 1: print "Joystick is initialized" 


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
		"""if event.type != QUIT: 
		    print '%s: %s' % (pygame.event.event_name(event.type), event.dict)"""
			
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
	speed=128
	direction=128
	input( pygame.event.get() )
	if up:
	  speed = 230
	if down:
	  speed = 30
	if left:
	  direction = 30
	if right:
	  direction = 200
	  
	jspeed =  j.get_axis(3)
	jdirection = j.get_axis(0)
	#comando gamecube
	if jspeed < 0:
	   speed = int(-jspeed*185 + 128)
	else:
	   speed = int(-jspeed*142 + 128)
	   
	if (jdirection < 0):
	   direction = int(jdirection*139 + 128)
	else:
	   direction = int(jdirection*142 + 128)
	   
	
	if speed < 190 and speed > 64:
	  speed = 127
	if speed > 255:
	  speed = 255
	if speed < 0:
	  speed = 0
	  
	if direction > 255:
	  direction = 255
	if direction < 0:
	  direction = 0
	  
	  
	
	xorspeed= speed ^ 0x56
	xordirection = direction ^0x56
		
	ser.write(chr(0x00)+chr(0xFF)+chr(0x00)+chr(0xFF)+chr(0x00))
	ser.write(chr(0x46)+chr(0x67)+chr(0x50)+chr(speed)+chr(xorspeed)+chr(direction)+chr(xordirection))
	
	
	time.sleep(0.1)
