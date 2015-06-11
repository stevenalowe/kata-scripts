# script to copy kata step project to next step

# structure:
#
#    each kata step is in a separate folder in the source directory $1
#    the step folders are named consistently $2-N where N is the step number
#    the source step is $3
#    the destination step is $4
#

if [ $# -lt 4 ] ; then
	echo "--------------------------------------------------------------------------"
	echo "args: <sourcePath> <stepDirectoryPrefix> <sourceStep> <destStep>"
	echo ">>> this script copies a kata-step subdirectory to a new kata-step subdirectory"
	echo "for example, given this input structure:"
	echo ""
	echo "root/"
	echo "  src/step-1/"
	echo "    src/step-1/src/codeone.java"
	echo "    src/step-1/src/codetwo.java"
	echo ""
	echo "then executing ./copy-kata-step.sh root step- 1 2"
	echo "will create this structure:"
	echo "root/"
	echo "  src/step-1/"
	echo "    src/step-1/src/codeone.java"
	echo "    src/step-1/src/codetwo.java"
	echo "  src/step-2/"
	echo "    src/step-2/src/codeone.java"
	echo "    src/step-2/src/codetwo.java"
	echo ""
	echo "NOTE: the script assumes RELATIVE PATHS, executed from root of sourcePath"
	echo "--------------------------------------------------------------------------"
	exit 1
fi

echo "==========================================================================="
echo "starting process..."

SOURCEPATH="$1"
STEPDIRPREFIX="$2"
SOURCESTEP=$3
DESTSTEP=$4
OUTPUTFOLDER="$1/$2$4"

echo ""
echo "   SOURCEPATH: $SOURCEPATH"
echo "STEPDIRPREFIX: $STEPDIRPREFIX"
echo "   SOURCESTEP: $SOURCESTEP"
echo "     DESTSTEP: $DESTSTEP"
echo " OUTPUTFOLDER: $OUTPUTFOLDER"
echo ""

# destroy target directory if necessary
if [ -e $OUTPUTFOLDER ] ; then
	echo "removing existing output directory $OUTPUTFOLDER"
	rm -rf $OUTPUTFOLDER
fi

# make new directory
echo "creating new output directory $OUTPUTFOLDER"
mkdir $OUTPUTFOLDER

# copy source directory
echo "copying files from $SOURCEPATH/$STEPDIRPREFIX$SOURCESTEP/ to $OUTPUTFOLDER"
cp -R $SOURCEPATH/$STEPDIRPREFIX$SOURCESTEP/* $OUTPUTFOLDER

# shift to new directory
echo "shifting to output directory $OUTPUTFOLDER"
cd $OUTPUTFOLDER

# rename .iml file
echo "renaming $STEPDIRPREFIX$SOURCESTEP.iml to $STEPDIRPREFIX$DESTSTEP.iml"
mv $STEPDIRPREFIX$SOURCESTEP.iml $STEPDIRPREFIX$DESTSTEP.iml

# remove .idea/workspace.xml file
echo "removing workspace.xml file"
rm .idea/workspace.xml

# return to start directory
echo "shifting back to origin directory"
cd ..

# done - upload to github/bitbucket/etc manually for now
echo "done creating $OUTPUTFOLDER project"
echo "...process completed."
echo "==========================================================================="

