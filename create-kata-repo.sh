# script to create sequential-branch repo from multiple projects

# structure:
#
#    each kata step is in a separate folder in the source directory $1
#    the kata's repo README.md file is in $1/doc
#    the step folders are named consistently $2-N where N is the step number
#    the number of steps is $3
#    the output folder is $4, which will be destroyed and recreated by this script
#

if [ $# -lt 4 ] ; then
	echo "-----------------------------------------------------------------------"
	echo "args: <sourcePath> <stepDirectoryPrefix> <numberOfSteps> <outputFolder>"
	echo ">>> this script flattens subdirectories into branches in a single repo "
	echo "for example, given this input structure:"
	echo ""
	echo "src/"
	echo "  src/README.md   <-- this is REQUIRED"
	echo "  src/step-1/"
	echo "    src/step-1/src/codeone.java"
	echo "    src/step-1/src/codetwo.java"
	echo "  src/step-2/"
	echo "    src/step-2/src/codeone.java"
	echo "    src/step-2/src/codetwo.java"
	echo ""
	echo "then executing ./create-kata-repo.sh src step- 2 out"
	echo "will create a repo in out with 2 branches, step-1 and step-2"
	echo "-----------------------------------------------------------------------"
	exit 1
fi

SOURCEPATH="$1"
STEPDIRPREFIX="$2"
NUMBEROFSTEPS=$3
OUTPUTFOLDER="$4"

# destroy existing directory/repo if necessary
if [ -e $OUTPUTFOLDER ] ; then
	rm -rf $OUTPUTFOLDER
fi

# make new directory
mkdir $OUTPUTFOLDER

# shift to new directory
cd $OUTPUTFOLDER

# create empty repo
git init

# copy repo README.md file master
cp ../$SOURCEPATH/README.md .

# add README.md file to repo and commit
git add .
git commit -m "initial commit of README.md file for $SOURCEPATH"

# copy files and create branches

STEPCOUNT=1
while [ $STEPCOUNT -le $NUMBEROFSTEPS ] ; do

  # track progress
  echo "creating branch STEP-$STEPCOUNT"

	# start branch for step
	git branch STEP-$STEPCOUNT
	git checkout STEP-$STEPCOUNT

	# copy files for step
	cp ../$SOURCEPATH/$STEPDIRPREFIX$STEPCOUNT/* .

	# add to branch
	git add .

	# commit to branch
	git commit -m "added files for step $STEPCOUNT"

  # merge with master (but keep branch, don't delete)
  git checkout master
  git merge STEP-$STEPCOUNT

  STEPCOUNT=`expr $STEPCOUNT '+' 1`

done

# return to start directory
cd ..

# done - upload to github/bitbucket/etc manually for now
echo "done creating $OUTPUTFOLDER repo"

