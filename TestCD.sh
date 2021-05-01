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
GNUPLOT_C=./tmp_gnuplotC.$$
GNUPLOT_D=./tmp_gnuplotD.$$
G4BL='./M20.g4bl'
GMINUIT=./tmp_gminuit.$$
SCRIPT=./tmp_script.$$
PROFILE_GNUPLOT=./tmp_profile_gp
PROFILE_C='m20bl_profileC.txt'
PROFILE_D='m20bl_profileD.txt'
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
mkfifo $GNUPLOT_C
gnuplot <$GNUPLOT_C >/dev/null &
exec 3>$GNUPLOT_C   # keep the pipe open as long as we are alive

mkfifo $GNUPLOT_D
gnuplot <$GNUPLOT_D >/dev/null &
exec 4>$GNUPLOT_D   # keep the pipe open as long as we are alive

cat <<-labels | tee -a ./tmp_gnuplot.dbug > $GNUPLOT_C
	set label "Q1" at 1300,150 center font ",\$fontsize"
	set label "Q2" at 1950,175 center font ",\$fontsize"
	set label "Scraper" at 3000,-150 center font ",\$fontsize"
	set label "B1" at 4560,160 center font ",\$fontsize"
	set label "Sep1" at 7230,-120 center font ",\$fontsize"
	set label "Q3" at 8750,175 center font ",\$fontsize"
	set label "Q4" at 9300,140 center font ",\$fontsize"
	set label "Q5" at 9850,175 center font ",\$fontsize"
	set label "Q6" at 10380,140 center font ",\$fontsize"
	set label "Q7" at 11350,175 center font ",\$fontsize"
	set label "Sep2" at 12430,-120 center font ",\$fontsize"
	set label "B2" at 15069,-160 center font ",\$fontsize"
	set label "Q8" at 15940,175 center font ",\$fontsize"
	set label "Q9" at 16500,165 center font ",\$fontsize"
	set label "Kicker" at 18330,150 center font ",\$fontsize"
	set label "C-Q10" at 23950,-165 center font ",\$fontsize"
	set label "C-Q11" at 24500,-175 center font ",\$fontsize"
	set label "C-Q12" at 25500,-185 center font ",\$fontsize"
	
labels


cat <<-labels | tee -a ./tmp_gnuplot.dbug > $GNUPLOT_D
	set label "Q1" at 1300,150 center font ",\$fontsize"
	set label "Q2" at 1950,175 center font ",\$fontsize"
	set label "Scraper" at 3000,-150 center font ",\$fontsize"
	set label "B1" at 4560,160 center font ",\$fontsize"
	set label "Sep1" at 7230,-120 center font ",\$fontsize"
	set label "Q3" at 8750,175 center font ",\$fontsize"
	set label "Q4" at 9300,140 center font ",\$fontsize"
	set label "Q5" at 9850,175 center font ",\$fontsize"
	set label "Q6" at 10380,140 center font ",\$fontsize"
	set label "Q7" at 11350,175 center font ",\$fontsize"
	set label "Sep2" at 12430,-120 center font ",\$fontsize"
	set label "B2" at 15069,-160 center font ",\$fontsize"
	set label "Q8" at 15940,175 center font ",\$fontsize"
	set label "Q9" at 16500,165 center font ",\$fontsize"
	set label "Kicker" at 18330,150 center font ",\$fontsize"
	set label "D-Q10" at 23950,-165 center font ",\$fontsize"
	set label "D-Q11" at 24500,-175 center font ",\$fontsize"
	set label "D-Q12" at 25500,-185 center font ",\$fontsize"
	
labels


if [ -f lastbest_gminuit ]
then
	cat ./lastbest_gminuit >$GMINUIT
else
	cat <<-! >$GMINUIT
param P 28.59065 28.0 30.0 0.5 fixed
param dP 3 0.1 0.9 0.1 fixed
param dX 10.0 0.0 10 0 fixed
param dY 5.0 0.0 10 0 fixed
param dXp 0.025 0.0 0.5 0 fixed
param dYp 0.025 0.0 0.5 0 fixed
param Q1 -33.954834 -100 0 3 fixed
param Q2 72.803772 -100 100 5 fixed
param B1 91.715524 60 120 5 fixed
param Q3 81.159428 0 100 5 fixed
param Q4 -54.086886 -200 0 5 fixed
param Q5 38.910438 0 200 5 fixed
param Q6 -81.120617 -200 0 5 fixed
param Q7 93.801147 0 100 10 fixed
param B2 92.842371 60 120 5 fixed
param Q8T 0.061972332 -1 1 0.1 fixed
param Q8B 49.142003 -150 150 3 fixed
param Q9 -2.6113863 -150 150 5 fixed
param Q10DB 0.0021351042 -0.1 0.1 0.01 fixed
param Q10DT -0.80486429 -200 200 5 fixed
param Q10CB -0.011088366 -0.1 0.1 0.01 fixed
param Q10CT 3.8929161 -200 200 5 fixed
param Q11DL -0.062298353 -0.1 0.1 0.01 fixed
param Q11DR -72.977205 -200 200 5 fixed
param Q11CL 0.07716875 -0.1 0.1 0.01 fixed
param Q11CR -79.319223 -200 200 5 fixed
param Q12D 103.84862 -200 200 5 fixed
param Q12C 106.57949 -200 200 3 fixed
param SM1D 573.41212 400 775 20 fixed
param SM1C 586.60508 400 775 20 fixed
param K1 -10000 -10000 0 25 limited
param XSLIT0 170 0 175 20 fixed
param YSLIT1 170 0 175 20 fixed
param XSLIT1D 170 0 175 20 fixed
param XSLIT1C 170 0 175 20 fixed
script $SCRIPT value 1
minuitcmd "SIMPLEX 950,0.005"
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


# M20 Separator2
11450.9894 200
11450.9894 120
13410.9894 120
13410.9894 200

11450.9894 -200
11450.9894 -40
13410.9894 -40
13410.9894 -200


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

if	[ "$HOSTNAME" = "musimr" ]; then nCores="52"; elif [ "$HOSTNAME" = "musim0" ]; then nCores="10"; else nCores="6"; fi 
echo >&2 Executing: G4BL with \$nCores cores, Nfomlimit=1 nEvents=300000 "\$@"
g4blmpi \$nCores "$G4BL" BL=2 nEvents=300000 gminuit=1 PROFILE=$PROFILE_C PROFILE_GNUPLOT=$PROFILE_GNUPLOT	 "\$@" >$OUT 2>&1;
g4blmpi \$nCores "$G4BL" BL=1 nEvents=300000 gminuit=1 PROFILE=$PROFILE_D PROFILE_GNUPLOT=$PROFILE_GNUPLOT	 "\$@" >$OUT 2>&1 # \$(<paramfile.g4bl)

echo >$GNUPLOT_D 'plot [0:26500][-200:200] "$PROFILE_D" using 1:(1.414*\$4) with lines title "1*sigmaX", "$APERTURE" with lines notitle, "$PROFILE_D" using 1:(-1.414*\$6) with lines title "-1*sigmaY", "$PROFILE_D" using 1:(\$2/300) with lines title "Nmu"'

echo >$GNUPLOT_C 'plot [0:26500][-200:200] "$PROFILE_C" using 1:(1.414*\$4) with lines title "1*sigmaX", "$APERTURE" with lines notitle, "$PROFILE_C" using 1:(-1.414*\$6) with lines title "-1*sigmaY", "$PROFILE_C" using 1:(\$2/300) with lines title "Nmu"'

# chisq = sum of sigmaX^2 and sigmaY^2 multiplied with a normalized muon population at the end at Z=26278
FOM_C=\`awk <$PROFILE_C '/^26278/{print (\$3*\$3+\$4*\$4+\$5*\$5+\$6*\$6)*(300000/(\$2+1))^2}'\`
FOM_D=\`awk <$PROFILE_D '/^26278/{print (\$3*\$3+\$4*\$4+\$5*\$5+\$6*\$6)*(300000/(\$2+1))^2}'\`
D_count=\`awk <$PROFILE_D '/^26278/{print (\$2+1)}'\`
C_count=\`awk <$PROFILE_C '/^26278/{print (\$2+1)}'\`
eval "\$@"
if ["\$FOM_C" == ""]; 
    then FOM=9E30;
elif ["\$FOM_D" == ""];
    then FOM=9E30;
else FOM=\`awk "BEGIN{print (\$FOM_C*\$FOM_D)}"\`;
fi

# To Optimize both legs version 1:
#else FOM=\`awk "BEGIN{print (if [(\$FOM_C)<(\$FOM_D)]; then \$FOM_D; else \$FOM_C) fi}"\`;
# To optimize both legs version 2 (used):
#else FOM=\`awk "BEGIN{print (\$FOM_C*\$FOM_D)}"\`;
# To optimize Kicker value to turn the beam away from one leg (didn't seem to work):
#else FOM=\`awk "BEGIN{print (\$FOM_C*(\$D_count+1)*(\$K1*\$K1)+1)}"\`;
echo >&2 "Chisq=\$FOM   \$@"
echo "\$FOM"
!

chmod +x $SCRIPT
gminuit $GMINUIT

# omit the line indicating that gnuplot terminated
exec 1>/dev/null 2>&1