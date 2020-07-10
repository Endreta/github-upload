'https://www.youtube.com/watch?v=r31mwJ0prCw

CON
  _clkmode   = xtal1 + pll16x                           
  _xinfreq   = 5_000_000                                'Set to standard clock mode and frequency (80 MHz)
  ping_pin = 8
  Speaker = 7

obj

  freq : "PingNoiseLED"
  ping : "Ping"
  pst: "Parallax Serial Terminal" 


var
long cog[2]
long Stack[40]   

long inches

long distance[2]  'declare distance array with 2 locations for 2 pings
Byte FrontDoorbuttonOn
Byte BackDoorbuttonOn
Byte KitchenPingOn
Byte LivingPingOn
byte x
byte y



Pub Serialstart               ' needed this to be a seperate method because there is a loop leading back to ArmAlarm and it took too long to initialize each time
    pst.Start(115_200)          'start serial terminal                                              
    ArmSensors
    
Pub ArmSensors     ' checks to see if any sensor has been tripped
dira[0..5]~~                                                          

     repeat

        if ina[13] == 1 and x == 0       ' arms system
          repeat until ina[13] == 0
          x := 1
          FlagReset
          outa[0]~~
          chime
          
          StartCogs
                                                            
        if ina[13] and x                 ' disarms system
          repeat until ina[13] == 0
          x := 0
          FlagReset
          Chime  
          StopCogs 
          
        if  ((FrontDoorbuttonOn == 1)  or  (BackDoorbuttonOn == 1)   or (KitchenPingOn == 1)  or (LivingPingOn == 1) ) And x == 1
          intruder

PUB Chime | i
if x == 1
  repeat i from 1 to 5              '5 second delay
    freq.frequency(Speaker,30_000)
    waitcnt(clkfreq/3 + cnt)
    freq.frequency(Speaker,50_000)
    waitcnt(clkfreq/3 + cnt)
    freq.frequency(Speaker,0)
    waitcnt(clkfreq/3 + cnt)
  freq.frequency(Speaker,50_000)
  waitcnt(clkfreq/5 + cnt)
  freq.frequency(Speaker,0)
if x == 0
  freq.frequency(Speaker,0)
  waitcnt(clkfreq/5 + cnt)
  freq.frequency(Speaker,50_000)
  waitcnt(clkfreq/5 + cnt)
  freq.frequency(Speaker,20_000)
  waitcnt(clkfreq/5 + cnt)
  freq.frequency(Speaker,30_000)
  waitcnt(clkfreq/5 + cnt)
  freq.frequency(Speaker,0)


Pub StartCogs  | i                                                  
    
          cog[0] := (cognew(pings, @stack)+1) 'new cog for pings
          cog[1] := (cognew(FrontDoorButton, @stack[20])+1)
          cog[2] := (cognew(BackDoorButton, @stack[30])+1)          
     


Pub StopCogs

if (Cog[0])
  cogstop(cog[0] - 1)
if (Cog[1])
  cogstop(cog[1] - 1)  
if (Cog[2])
  cogstop(cog[2] - 1)
  
    

PUB FlagReset
dira[0..5]~~  
          outa[0..5] ~                     ' turns off leds and speaker
          freq.frequency(Speaker,0)
          FrontDoorbuttonOn := 0           'reset all flags to 0
          BackDoorbuttonOn := 0
          KitchenPingOn := 0
          LivingPingOn := 0  

pub pings |i,  range  'pings routine with var i and range
repeat
 repeat i from 0 to 1 'like for next loop
  range := ping.inches(ping_pin + i)
  distance[i] := range
  waitcnt(clkfreq/20 + cnt)              
  if distance[0] < 5  and distance[0] > 0   ' if motion detector in kitchen is trickered
    KitchenPingOn := 1
  if distance[1] < 5  and distance[1] > 0   ' if motion detector in livingroom is trickered
    LivingPingOn := 1  
  
 


PUB FrontDoorButton
  FrontDoorbuttonOn := 0  

repeat
  if ina[15] == 1
    repeat until ina[15] == 0  
    FrontDoorbuttonOn := 1       

   


PUB BackdoorButton
 backDoorbuttonOn := 0 

repeat
  if ina[14] == 1
    repeat until ina[14] == 0      
    backDoorbuttonOn := 1       

    


PUB Intruder
dira[0..1]~~

  if  frontDoorButtonOn == 1                                         
    outa[2]~~ 

  if  BackDoorbuttonOn == 1                                          
    outa[3]~~ 

  if distance[0] < 5  and distance[0] > 0
    outa[4]~~                                                        
   
  if distance[1] < 5  and distance[1] > 0                                               
   outa[5]~~                                                            
 

  repeat
    Outa[1]~~
    Outa[0]~
    freq.frequency(Speaker,20_000)
    waitcnt(clkfreq/5 + cnt)
    Outa[0]~~
    Outa[1]~
    freq.frequency(Speaker,30_000)
    waitcnt(clkfreq/5 + cnt)
    ArmSensors

