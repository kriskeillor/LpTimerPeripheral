graph TD
  main
  K22FDRM_BootClock[K22FDRM_BootClock<br>Initialize the clock at 20.9 MHz.]
  ClkInit[ClkInit<br>Enables port clocking and LpTmr.]
  IOShieldInit[IOShieldInit<br>Initialize Diode & Switch GPIO ports.]
  Write7Seg[Write7Seg<br/>Increment the number displayed on the 7SEG, branch to LEDWrite,<br>then reset the 7SEG display code if necessary.]
  SwRead[SwRead<br>Read the switches for a frequency input.<br>Loops endlessly -- flow diagram on next page.]

  main --> K22FDRM_BootClock
  K22FDRM_BootClock --> ClkInit
  ClkInit --> IOShieldInit
  IOShieldInit --> Write7Seg
  Write7Seg --> SwRead