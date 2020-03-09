graph TD
  MainLp
  ReadSw[ReadSw<br/>Read the switches for a frequency input.]
  SwChange{Did the switch read<br/>change from LastSw?}
  UpdateCMR[UpdateCMR<br/>Disable the timer, update the Compare Value,<br/>then re-enable the timer.]
  ReadTCF[ReadTCF<br/>Check the timer's Compare Flag.]
  TCFChange{Is the timer's<br/>Compare Flag set?}
  Update7Seg[Update7Seg<br/>Increment the number<br/>displayed on the 7SEG.]
  ResetTCF[ResetTCF<br/>Set the TCF to trigger a hardware clear<br/>and restart the timer.]
  Reloop[Loop MainLp.]

  MainLp --> ReadSw
    ReadSw --> SwChange
    SwChange --> |Yes|UpdateCMR
      UpdateCMR --> ReadTCF
    SwChange -->|No|ReadTCF
      ReadTCF -->TCFChange
        TCFChange -->|Yes|Update7Seg
          Update7Seg --> ResetTCF
          ResetTCF --> Reloop
        TCFChange -->|No|Reloop
    Reloop --> MainLp