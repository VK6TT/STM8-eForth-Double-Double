\ *** Important - Res D2 D1 must be in "shortmem"
\ so define these first

\ Assumed MSB stored first
\ M=D1xD2
\ Change Log
\ used ]M! to copy op-codes into definition instead of using Jumps and Returns
NVM
Variable Res 8 allot \ Res is 16 bytes for double * double
Variable D1 4 allot \ Double1 - destroyed by routine
Variable D2 4 allot \ Double2  - preserved
Variable Carry      \ loaded with carry bit
VAriable Test       \ if you point ]M! to blank memory lets not go on till a crash
RAM
\ These words are only required during compiling. Not needed afterwards
: RCF $98 C, ; IMMEDIATE \ reset carry flag
: CLR_A  $4F C, ; IMMEDIATE \ clear accum

\ rotate byte logical left through carry
: ]RLC ( c -- ) $39 C, C, ] ; IMMEDIATE 

: ]LDA ( c -- ) $B6 C, C, ] ; IMMEDIATE \ load byte @ c into accum
: ]ADC ( c -- ) $B9 C, C, ] ; IMMEDIATE \ add byte at c to accumulator
: ]LDA>M ( c -- ) $B7 C, C, ] ; IMMEDIATE \ save A to memory
: ]M! ( A -- ) \ copy bytes from A to this definition until $81 ( ret ) 
   DEPTH 0= ABORT" Empty Stack" 
   0 TEST !
   BEGIN
      DUP
      C@ DUP 
      $81 = NOT
      IF C, 1+ 0 \ fetch the char and save it to HERE
      ELSE -1
      THEN
      1 TEST +! TEST @ 48 = 
      DUP IF ." byte limit!!" THEN
      OR \ 4test - no runaways
   UNTIL
   2DROP  \ discard A and C
   ]
   ; 

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
: CARRY! ( -- ) \ save carry bit to variable CARRY
   [ $9011 ,  CARRY C, 0 C, ]
;
: D1! ( DL Dh -- )      \ save Dl Dh
   swap D1 2! ; 
: D2! ( DL Dh -- )      \ save Dl Dh
   swap D2 2! \ save Dl Dh 
   ;
   
: D1xD2 \ calcualte Res for loading into DDS
   Res 8 ERASE 
   32 0 DO
      [ ' RL_D1 ]M!        \ rotate D1 to left
      [ ' Carry! ]M!   \ save carry
      [ ' RLM ]M!      \ rotate Res to left
      [ Carry ]C@      \ fetch carry bit
      IF +!Result \ add D2 to M
      THEN
   LOOP
   ;
RAM
