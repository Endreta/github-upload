OBJ

  
  ping  : "Ping"
  pst: "Parallax Serial Terminal"       

CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  ping_pin = 6
        

PUB Go | range , time

dira[0..5] ~~

 pst.Start(115_200)          'start serial terminal

    



   
    
      range := ping.Inches(ping_pin)  ' Get range in inches
      if range < 2                    'if range is less than 2in turn on led      
        outa[0..5] := %111111
        Frequency(7,50_000)  
      elseif  range < 3                     'if range is less than 3in turn on led    
        outa[0..5] := %111110
         Frequency(7,40_000) 
      elseif  range < 4                     'if range is less than 4in turn on led   
        outa[0..5] := %111100
         Frequency(7,35_000) 
      elseif  range < 5                     'if range is less than 5in turn on led   
        outa[0..5] := %111000
         Frequency(7,30_000) 
      elseif  range < 6                     'if range is less than 6in turn on led   
        outa[0..5] := %110000
         Frequency(7,25_000) 
      elseif  range < 7                     'if range is less than 7in turn on led   
        outa[0..5] := %100000
         Frequency(7,20_000) 
      else
        outa[0..5] ~
        Frequency(7,0) 
      pst.Str(String(pst#NL, "range = ")) 'display value of range in serial terminal
      pst.Dec(range) 
         
      WaitCnt(ClkFreq / 10 + Cnt)
 

PUB Frequency(pin, freq)

  'Configure ctra module 
  ctra[30..26] := %00100               ' Set ctra for "NCO single-ended"
  ctra[5..0] := 7                     ' Set APIN to P7                          
  frqa := freq                           
  dira[pin]~~                           ' Set P7 to output

           