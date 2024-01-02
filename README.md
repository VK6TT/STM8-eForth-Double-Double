# STM8-eForth-Double-Double
Multiplying two 32 bit integers to get a 64 bit result

I needed this to calculate the tuning word for a AD9850 DDS chip. Please note that 
the constraint that the arrays used (Res, D1 and D2) must reside in Shortmem i.e. the first 256 bytes of ram. If you wish to locate them outside this then some minor changes would be needed for the longmem adressing, and
the 32 bit doubles and 64 bit result are stored MSB first. That's different from the way STM8 eForth stores and retrieves doubles. Dealt with by the swap in "D1!".

A loop of 10,000 calcualtions, which included loading the data and initialising each time, took about 7.5 seconds in total. That is way faster than I had hoped for and exceeds what I needed in my DDS controller applicaiton. 

Identification of the Carry is imporved thanks to the BCCM op code.

No, I don't yet see any obvious ways to make it go faster or use less space.

Looking forward to seeing how you might improve this.
