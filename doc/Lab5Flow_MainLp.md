graph TD
  Entry(Entry)
  MainLp[MainLp<br/>Check the timer's Compare Flag.]
  SwRead[SwRead<br/>Read the switches for a frequency input.]
  SwChange{Did the switch read<br/>change from LastSw?}
  UpdateCMR[UpdateCMR<br/>Disable the timer, update the Compare Value,<br/>then re-enable the timer.]
  TCFChange{Is the timer's<br/>Compare Flag set?}
  Write7Seg[Write7Seg<br/>Increment the number displayed on the 7SEG, branch to LEDWrite,<br>then reset the 7SEG display code if necessary.]
  LEDWrite[LEDWrite<br>Writes data to diode control pins.]
  ClearTCF[ClearTCF<br>Clear the TCF flag but keep the timer enabled.]
  Reloop(Loop SwRead.)

  Entry --> SwRead
    SwRead --> SwChange
    SwChange --> |Yes|UpdateCMR
      UpdateCMR --> MainLp
    SwChange -->|No|MainLp
    MainLp --> TCFChange
        TCFChange -->|Yes|ClearTCF
          ClearTCF --> Write7Seg
          Write7Seg --> LEDWrite
          LEDWrite --> Write7Seg
          Write7Seg --> Reloop
        TCFChange -->|No|Reloop
    Reloop --> SwRead