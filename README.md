

This is a simulation of the M20 beamline
  written by Tunok Mondol, Winter 2021
  Additional files needed to run this g4bl file:
  Kickerfield.txt, 12dq12map.txt, 12q12map.txt and
  BOpera9ASep.txt

![alt text](https://github.com/[username]/[reponame]/blob/[branch]/image.jpg?raw=true)

Simulation to date April, 2021.
	Things that need to be resolved: 
		a) The Separator fields (the physical dimensions of plate gap and magnet gap are that of M20) are from that of M9A Separators.
		b) The Septum Magnet was simply implemented with 2 "idealsectorbend" one beside the other and length was optimized with GMINUIT for reducing 
    "misalignment". A correct fieldmap should be implemented.

 	Simulation is tuned only for muon focusing and max luminosity. Non-spin rotation, particle decays, Pion production, Cloud muons. etc not considered.
 	12q12 Quadrupole and 12dq12 QuadSteering fields introduced, however the conversion of 12dq12 & 12q12 into current for steering is required.
 	Intermediate beam pipes: Q2pipe,ChicagoPipe,Bend1_Sep1pipe,Sep2_Bend2pipe,Q8_9pipe,Q10_12pipe are designed and placed with guesses.
 	Genericbends are placed in between two 'corner' commands with each having the half-angle of the bending angle, as per suggestions by Fred Jones.
  
  
