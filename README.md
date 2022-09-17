

This is a simulation of the M20 beamline.
  Additional files needed to run this g4bl file:
  Kickerfield.txt, 12dq12map.txt, 12q12map.txt and
  BOpera9ASep.txt


<img width="400" alt="Screen Shot 2021-04-22 at 3 29 41 PM" src="https://user-images.githubusercontent.com/53085784/190866403-178dc4a8-34e9-4afd-9318-3ab0aa83818a.png">

Simulation to date April, 2021.
	Things that need to be resolved: 
		a) The Separator fields (the physical dimensions of plate gap and magnet gap are that of M20) are from that of M9A Separators.
		b) The Septum Magnet was simply implemented with 2 "idealsectorbend" one beside the other and length was optimized with GMINUIT for reducing 
    "misalignment". A correct fieldmap should be implemented.

<img width="400" alt="Screen Shot 2021-04-18 at 4 31 50 PM" src="https://user-images.githubusercontent.com/53085784/190866516-2c88fd96-8eea-426b-86e2-0fe6af5b408e.png">

 	Simulation is tuned only for muon focusing and max luminosity. Non-spin rotation, particle decays, Pion production, Cloud muons. etc not considered.
 	12q12 Quadrupole and 12dq12 QuadSteering fields introduced, however the conversion of 12dq12 & 12q12 into current for steering is required.
 	Intermediate beam pipes: Q2pipe,ChicagoPipe,Bend1_Sep1pipe,Sep2_Bend2pipe,Q8_9pipe,Q10_12pipe are designed and placed with guesses.
 	Genericbends are placed in between two 'corner' commands with each having the half-angle of the bending angle, as per suggestions by Fred Jones.
  
  
