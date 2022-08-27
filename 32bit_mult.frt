\ *** Important - Res D2 D1 must be in "shortmem"
\ so define these first

\ Assumed MSB stored first
\ M=D1xD2
NVM
Variable Res 8 allot \ Res is 16 bytes for double * double
Variable D1 4 allot \ Double1 - destroyed by routine
Variable D2 4 allot \ Double2  - preserved
Variable Carry      \ loaded with carry bit

RAM
\ These words are only required during compiling. Not needed afterwards
: RCF $98 C, ; IMMEDIATE \ reset carry flag
: CLR_A  $4F C, ; IMMEDIATE \ clear accum

\ rotate byte logical left through carry
: ]RLC ( c -- ) $39 C, C, ] ; IMMEDIATE 

: ]LDA ( c -- ) $B6 C, C, ] ; IMMEDIATE \ load byte @ c into accum
: ]ADC ( c -- ) $B9 C, C, ] ; IMMEDIATE \ add byte at c to accumulator
: ]LDA>M ( c -- ) $B7 C, C, ] ; IMMEDIATE \ save A to memory

NVM
: RL_D1 ( -- ) \ rotate D1 to left
   RCF
   [ D1 3 + ]RLC
   [ D1 2 + ]RLC
   [ D1 1 + ]RLC
   [ D1 ]RLC
;   
   
: RLM ( -- ) \ rotate Res to left
   RCF
   [ Res 7 + ]RLC
   [ Res 6 + ]RLC
   [ Res 5 + ]RLC
   [ Res 4 + ]RLC
   [ Res 3 + ]RLC
   [ Res 2 + ]RLC
   [ Res 1 + ]RLC
   [ Res ]RLC
;
: +!Result \ Add D2 to M
   RCF \ not needed if ADC replaced with ADD on next row
   [ Res  7 + ]LDA [ D2 3 + ]ADC  [ Res 7 + ]LDA>M
   [ Res  6 + ]LDA [ D2 2 + ]ADC  [ Res 6 + ]LDA>M
   [ Res  5 + ]LDA [ D2 1 + ]ADC  [ Res 5 + ]LDA>M
   [ Res  4 + ]LDA [ D2     ]ADC  [ Res 4 + ]LDA>M
   CLR_A [ Res  3 + ]ADC  [ Res 3 + ]LDA>M
   CLR_A [ Res  2 + ]ADC  [ Res 2 + ]LDA>M
   CLR_A [ Res  1 + ]ADC  [ Res 1 + ]LDA>M
   CLR_A [ Res      ]ADC  [ Res     ]LDA>M
;
: CARRY? ( -- D2 ) \ return carry bit
   CLR_A 
   [ $3F C, Carry C, ] \ force carry variable to zero
   [ Carry ]adc         \ A now holds C flag
   [ Carry ]LDA>M       \ Save A to Carry
   Carry C@             \ push Carry onto stack
;
: D1! ( DL Dh -- )      \ save Dl Dh
   swap D1 2! ; 
: D2! ( DL Dh -- )      \ save Dl Dh
   swap D2 2! \ save Dl Dh 
   ;
   
: D1xD2 \ calcualte Res for loading into DDS
   32 0 DO
      RL_D1         \ rotate D1 to left
      Carry?   \ was carry set?
      IF RLM      \ rotate Res to left 
         +!Result \ add D2 to M
      ELSE  RLM   \ rotate Res to left
      THEN
   LOOP
   ;
RAM
