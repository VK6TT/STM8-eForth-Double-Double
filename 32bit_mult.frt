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

   
: mydump   D1 1 dump cr
   D2 1 dump cr
   Res 1 dump cr
   cr cr
   ;
\ M=SxF = 1DA7B0B3 1DA7B0B34E8800
: F# $DC $F280 D2! ;
: S#  $225C $17D0 D1! ; \  high low 
: (t)   S# F#  
   Res 8 erase 
;
: T  (t) D1xD2  mydump ;

: speed T T T T T T T T T T ;  
: a (t) RL_D1 Carry? mydump ;
: B RL_D1 Carry? mydump ;
: c D1! D2! Res 8 erase mydump ;
: d 
   (t) 
   31 0 do
      RL_D1
      Carry?  
      I .  . mydump cr
   LOOP
   mydump
   ;
$0 $1 $1234 $4567 c
























\ : ]RLC ( n -- ) $72 C, $59 C, , ] ; IMMEDIATE 
\ : ]RRC ( n -- ) $72 C, $56 C, , ] ; IMMEDIATE 
\ : ]LDA ( n -- ) $C6 C, , ] ; IMMEDIATE \ load byte @ n into accum
\ : ]ADC ( n -- ) $C9 C, , ] ; IMMEDIATE \ add byte at n to accumulator
\ : ]LDA>M ( n -- ) $C7 C, , ] ; IMMEDIATE \ save A to memory
: +!Result \ Add D2 to M
   RCF
   [ Res 15 + ]LDA [ D2 8 + ]ADC  [ Res 15 + ]LDA>M
   [ Res 14 + ]LDA [ D2 7 + ]ADC  [ Res 14 + ]LDA>M
   [ Res 13 + ]LDA [ D2 6 + ]ADC  [ Res 13 + ]LDA>M
   [ Res 12 + ]LDA [ D2 5 + ]ADC  [ Res 12 + ]LDA>M
   [ Res 11 + ]LDA [ D2 4 + ]ADC  [ Res 11 + ]LDA>M
   [ Res 10 + ]LDA [ D2 3 + ]ADC  [ Res 10 + ]LDA>M
   [ Res  9 + ]LDA [ D2 2 + ]ADC  [ Res 9 + ]LDA>M
   [ Res  8 + ]LDA [ D2 1 + ]ADC  [ Res 8 + ]LDA>M
   [ Res  7 + ]LDA [ D2     ]ADC  [ Res 7 + ]LDA>M
   [ Res  6 + ]LDA [ ZERO  ]ADC  [ Res 6 + ]LDA>M
   [ Res  5 + ]LDA [ ZERO  ]ADC  [ Res 5 + ]LDA>M   \ not needed here down ?
   [ Res  4 + ]LDA [ ZERO  ]ADC  [ Res 4 + ]LDA>M
   [ Res  3 + ]LDA [ ZERO  ]ADC  [ Res 3 + ]LDA>M
   [ Res  2 + ]LDA [ ZERO  ]ADC  [ Res 2 + ]LDA>M
   [ Res  1 + ]LDA [ ZERO  ]ADC  [ Res 1 + ]LDA>M
   [ Res      ]LDA [ ZERO  ]ADC  [ Res     ]LDA>M
;
: RR_D1 ( -- ) \ rotate D1 to right
   RCF
   [ D1 ]RRC
   [ D1 1 + ]RRC
   [ D1 2 + ]RRC
   [ D1 3 + ]RRC
 \  [ D1 4 + ]RRC
 \  [ D1 5 + ]RRC
 \  [ D1 6 + ]RRC
 \  [ D1 7 + ]RRC
;   
   
: RLM ( -- ) \ rotate Res to left
   RCF
 \  [ Res 15 + ]RLC
 \  [ Res 14 + ]RLC
 \  [ Res 13 + ]RLC
 \  [ Res 12 + ]RLC
 \  [ Res 11 + ]RLC
 \  [ Res 10 + ]RLC
 \  [ Res 9 + ]RLC
 \  [ Res 8 + ]RLC
   [ Res 7 + ]RLC
   [ Res 6 + ]RLC
   [ Res 5 + ]RLC
   [ Res 4 + ]RLC
   [ Res 3 + ]RLC
   [ Res 2 + ]RLC
   [ Res 1 + ]RLC
   [ Res ]RLC
;

: c? 
0 ZERO ! [ $4f c, \ clr accum  
 zero ]adc
[ zero     ]LDA>M 
zero @
0 ZERO !
;
: Tc ( -- ) \ test carry
   D1 1 dump cr
   RCF c?
   [ D1 ]RRC c?
   [ D1 1 + ]RRC c?
   [ D1 2 + ]RRC c?
   [ D1 3 + ]RRC c?
   
;   
: c>0 
 [ $4f c, \ clr accum  
 zero ]adc
[ zero     ]LDA>M ;
: Done? D1 2@ 0= swap 0= and ;   
: RR_D1 ( -- ) \ rotate D1 to right
   RCF
   [ D1 ]RRC
   [ D1 1 + ]RRC
   [ D1 2 + ]RRC
   [ D1 3 + ]RRC
;   
: ]RRC ( n -- ) $36 C, C, ] ; IMMEDIATE 
