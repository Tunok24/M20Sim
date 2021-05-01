###
### check for required programs
###
EXIT=0
if ! type g4bl >/dev/null 2>&1
then
	echo The program g4beamline is required.
	echo It is available in Computer Programs at http://muonsinc.com .
	EXIT=1
fi
if ! type gminuit >/dev/null 2>&1
then
	echo The program gminuit is required.
	echo It is available in Computer Programs at http://muonsinc.com .
	EXIT=1
fi
if ! type wish >/dev/null 2>&1
then
	echo You need to have your system administrator install Tcl/Tk
	EXIT=1
fi
if ! type tclsh >/dev/null 2>&1
then
	echo You need to have your system administrator install Tcl/Tk
	EXIT=1
fi
if ! type gnuplot >/dev/null 2>&1
then
	echo You need to have your system administrator install gnuplot
	EXIT=1
fi

if test $EXIT != 0; then exit $EXIT; fi

###
### define temp files used
###
GNUPLOT=./tmp_gnuplot.$$
G4BL='./M20.g4bl'
GMINUIT=./tmp_gminuit.$$
SCRIPT=./tmp_script.$$
PROFILE_GNUPLOT=./tmp_profile_gp
PROFILE='m20bl_profileC.txt'
APERTURE=./tmp_aperture.$$
OUT=./tmp_out.$$
HISTORY=./fitHistory
RUN_START_DATE=$(date "+%d-%m-%y_%H-%M")

if [ -f "$G4BL" ]
then
	echo g4bl input file $G4BL
else
	echo g4bl input file not found
	EXIT=1
fi

cat /dev/null > $HISTORY

trap "kill %1 >/dev/null 2>&1; rm -f $GNUPLOT $GMINUIT $PROFILE_GNUPLOT\
		$SCRIPT $APERTURE $OUT $HISTORY rank*" 0 1 2 3

#clean up old gnuplot & other files which might prevent intializing correctly
if [ -f $GNUPLOT ]; then rm $GNUPLOT; fi
if [ -f $APERTURE ]; then rm $APERTURE; fi
if [ -f $PROFILE_GNUPLOT ]; then rm $PROFILE_GNUPLOT; fi

###
### start gnuplot from a pipe, so a single plot window is used
###
mkfifo $GNUPLOT
gnuplot <$GNUPLOT >/dev/null &
exec 3>$GNUPLOT   # keep the pipe open as long as we are alive


cat <<-labels | tee -a ./tmp_gnuplot.dbug > $GNUPLOT
	set label "Q1" at 1300,150 center font ",\$fontsize"
	set label "Q2" at 1950,175 center font ",\$fontsize"
	set label "Scraper" at 3000,-150 center font ",\$fontsize"
	set label "B1" at 4560,160 center font ",\$fontsize"
	set label "Sep1" at 7230,-120 center font ",\$fontsize"
	set label "Q3" at 8750,-175 center font ",\$fontsize"
	set label "Q4" at 9300,-140 center font ",\$fontsize"
	set label "Q5" at 9850,-175 center font ",\$fontsize"
	set label "Q6" at 10380,-140 center font ",\$fontsize"
	set label "Q7" at 11350,-175 center font ",\$fontsize"
	set label "XSLIT0" at 11300,170 center font ",\$fontsize"
	set label "Sep2" at 12430,-120 center font ",\$fontsize"
	set label "YSLIT1" at 13560,-170 center font ",\$fontsize"
	set label "B2" at 15069,-160 center font ",\$fontsize"
	set label "Q8" at 15940,175 center font ",\$fontsize"
	set label "Q9" at 16500,165 center font ",\$fontsize"
	set label "Kicker" at 18330,150 center font ",\$fontsize"
	set label "Septum_C" at 21716,110 center font ",\$fontsize"
	set label "XSLIT1C" at 22321.6,170 center font ",\$fontsize"
	set label "D-Q10" at 23950,-165 center font ",\$fontsize"
	set label "D-Q11" at 24500,-175 center font ",\$fontsize"
	set label "D-Q12" at 25500,-185 center font ",\$fontsize"
	
labels


if [ -f lastbest_gminuit ]
then
	cat ./lastbest_gminuit >$GMINUIT
else
	cat <<-! >$GMINUIT
param P 28.830843 25 30 1 limited
param dP 3 0.0 4 0.1 fixed
param dX 10.0 0.0 10 0 fixed
param dY 5.0 0.0 10 0 fixed
param dXp 0.05 0.0 0.5 0 fixed
param dYp 0.05 0.0 0.5 0 fixed
param Q1 -35.092869 -37 -30 1 limited
param Q2 74.153194 70 75 1 limited
param B1 91.659896 85 100 1 limited
param Q3 87.03341 75 95 1 limited
param Q4 -78.701606 -90 -70 1 limited
param Q5 69.864461 60 70 1 limited
param Q6 -87.828481 -70 -100 1 limited
param Q7 98.737528 85 110 1 limited
param B2 92.473556 70 100 5 limited
param Q8T 0.20620102 -1 1 0.005 limited
param Q8B 41.810258 -100 100 2 limited
param Q9 -21.564409 -100 100 2 limited
param Q10DB -0.01663766 -1 1 0.005 fixed
param Q10DT 0.68211732 -100 100 2 fixed
param Q10CB -0.0087409701 -1 1 0.005 limited
param Q10CT 2.7418251 -20 20 2 limited
param Q11DL -0.61942555 -1 1 0.005 fixed
param Q11DR -75.573346 -200 200 1 fixed
param Q11CL 0.051537266 -0.1 0.1 0.01 limited
param Q11CR -77.658069 -100 -60 3 limited
param Q12D 111.17829 -200 200 2 fixed
param Q12C 104.79 90 130 3 limited
param SM1D 591.77515 450 775 5 fixed
param SM1C 537.82754 450 775 20 limited
param K1 -8408.1896 -5000 -9500 30 limited
param XSLIT0 170 0 175 20 fixed
param YSLIT1 170 0 175 20 fixed
param XSLIT1D 170 0 175 20 fixed
param XSLIT1C 170 0 175 20 fixed
script $SCRIPT value 1
minuitcmd "SIMPLEX 600,.001"
#minuitcmd HESSE
!
fi



echo "Created gminuit file $GMINUIT"
cat $GMINUIT #displays initial set of params on stdout

cat <<-! >$APERTURE
# M20 Q1
960.7804 200
960.7804 104.775
1659.2808 104.775
1659.2808 200

960.7804 -200
960.7804 -104.775
1659.2808 -104.775
1659.2808 -200


# M20 Q2
1711.198 200
1711.198 155.575
2212.848 155.757
2212.848 200

1711.198 -200
1711.198 -155.575
2212.848 -155.757
2212.848 -200


# M20 SCRAPER
2375.897 200
2375.897 152.4
2560.809 152.4
2560.804 127
3459.207 127
3459.207 101.6
4024.103 101.6
4024.103 200

2375.897 -200
2375.897 -152.4
2560.809 -152.4
2560.804 -127
3459.207 -127
3459.207 -101.6
4024.103 -101.6
4024.103 -200



# M20 B1
4292.038 200
4294.038 114.5
4952.038 114.5
4952.038 200

4292.038 -200
4294.038 -114.5
4952.038 -114.5
4952.038 -200


# M20 Separator1
6278.05 200
6278.05 120
8238.05 120
8238.05 200

6278.05 -200
6278.05 -40
8238.05 -40
8238.05 -200


# M20 Q3
8609.4832 200
8609.4832 155.575
8914.2832 155.575
8914.2832 200

8609.4832 -200
8609.4832 -155.575
8914.2832 -155.575
8914.2832 -200


# M20 Q4
9168.8658 200
9168.8658 98.4
9498.8658 98.4
9498.8658 200

9168.8658 -200
9168.8658 -98.4
9498.8658 -98.4
9498.8658 -200


# M20 Q5
9701.8848 200
9701.8848 98.4
10031.8848 98.4
10031.8848 200

9701.8848 -200
9701.8848 -98.4
10031.8848 -98.4
10031.8848 -200


# M20 Q6
10232.8464 200
10232.8464 98.4
10562.8464 98.4
10562.8464 200

10232.8464 -200
10232.8464 -98.4
10562.8464 -98.4
10562.8464 -200


# M20 Q7
10818.4958 200
10818.4958 155.575
11123.2958 155.575
11123.2958 200

10818.4958 -200
10818.4958 -155.575
11123.2958 -155.575
11123.2958 -200


# M20 XSLIT0
11300.9894 200
11300.9894 175


# M20 Separator2
11450.9894 200
11450.9894 120
13410.9894 120
13410.9894 200

11450.9894 -200
11450.9894 -40
13410.9894 -40
13410.9894 -200

# M20 YSLIT1
13560.9894 -200
13560.9894 -175


# M20 B2
14739.058 200
14739.058 114.5
15399.058 114.5
15399.058 200

14739.058 -200
14739.058 -114.5
15399.058 -114.5
15399.058 -200


# M20 Q8
15786.5064 200
15786.5064 155.575
16091.3064 155.575
16091.3064 200

15786.5064 -200
15786.5064 -155.575
16091.3064 -155.575
16091.3064 -200



# M20 Q9
16347.5162 200
16347.5162 155.575
16652.3162 155.575
16652.3162 200

16347.5162 -200
16347.5162 -155.575
16652.3162 -155.575
16652.3162 -200


# M20 KICKER
17193.5624 200
17193.5624 101.5
19466.5624 101.6
19466.5624 200

17193.5624 -200
17193.5624 -101.6
19466.5624 -101.6
19466.5624 -200


# M20 SEPTUM
21404.1418 200
21404.1418 88
22029.1418 88
22029.1418 200

21404.1418 -200
21404.1418 -113
22029.1418 -113
22029.1418 -200


# M20 XSLIT1C
22321.6418 200
22321.6418 175

# M20 D-Q10
23801.5018 200
23801.5018 155.575
24106.3018 155.575
24106.3018 200

23801.5018 -200
23801.5018 -155.575
24106.3018 -155.575
24106.3018 -200



# M20 D-Q11
24363.5022 200
24363.5022 155.575
24668.3022 155.575
24668.3022 200

24363.5022 -200
24363.5022 -155.575
24668.3022 -155.575
24668.3022 -200


# M20 D-Q12
24925.5026 200
24925.5026 155.575
25230.3026 155.575
25230.3026 200

24925.5026 -200
24925.5026 -155.575
25230.3026 -155.575
25230.3026 -200


0 0
262778 0
!

cat <<-! >$SCRIPT


time=\$(date "+%d-%m-%y %H-%M-%S")
echo -e "\\n *******start of script*********** \$time" | tee -a $HISTORY >&2

echo >&2 Executing G4BL with 48 cores, Nfomlimit=1 nEvents=1000000 "\$@"
g4blmpi 48 "$G4BL" BL=2 nEvents=1000000 gminuit=1 PROFILE_C=$PROFILE PROFILE_GNUPLOT=$PROFILE_GNUPLOT	 "\$@" >$OUT 2>&1

echo >$GNUPLOT 'plot [0:26300][-200:200] "$APERTURE" with lines notitle, "$PROFILE" using 1:(1.414*\$4) with lines title "sigmaX dP 0.3", "$PROFILE" using 1:(-1.414*\$6) with lines title "sigmaY dP 0.3", "$PROFILE" using 1:(\$2/5000) with lines title "Nmu"'

# chisq = sum of sigmaX^2 and sigmaY^2 multiplied with a normalized muon population at the end at Z=26278
FOM=\`awk <$PROFILE '/^26278/{print (\$3*\$3+\$4*\$4+\$5*\$5+\$6*\$6)*(1000000/(\$2+1))^2}'\`
if ["\$FOM" == ""]; 
 then FOM=9E19
fi
echo >&2 "Chisq=\$FOM   \$@"
echo "\$FOM"
!

chmod +x $SCRIPT
gminuit $GMINUIT

# omit the line indicating that gnuplot terminated
exec 1>/dev/null 2>&1