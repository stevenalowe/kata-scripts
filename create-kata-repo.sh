# script to create sequential-branch repo from multiple projects

# structure:
#
#    each kata step is in a separate folder in the source directory $1
#    the kata's repo README.md file is in $1/doc
#    the step folders are named consistently $2-N where N is the step number
#    the number of steps is $3
#    the output folder is $4, which will be destroyed and recreated by this script
#

if [ $# -lt 5 ] ; then
	echo "--------------------------------------------------------------------------"
	echo "args: <sourcePath> <stepDirectoryPrefix> <numberOfSteps> <outputFolder> <repoURL>"
	echo ">>> this script flattens subdirectories into branches in a single repo <<<"
	echo "for example, given this input structure:"
	echo ""
	echo "root/"
	echo "  README.md   <-- this is REQUIRED"
	echo "  step-1/"
	echo "    src/step-1/src/codeone.java"
	echo "    src/step-1/src/codetwo.java"
	echo "  step-2/"
	echo "    src/step-2/src/codeone.java"
	echo "    src/step-2/src/codetwo.java"
	echo ""
	echo "then executing"
	echo "  ../scripts/create-kata-repo.sh root step- 2 out https://github.com/stevenalowe/kata-1-refactoring-instanceof"
	echo "will create a repo in out with 2 branches, step-1 and step-2, and push it to the given URL"
	echo "NOTE: the script assumes RELATIVE PATHS, executed from root of sourcePath"
	echo "NOTE ALSO: you must create the repo at the given URL first, to properly collect the branches"
	echo "--------------------------------------------------------------------------"
	exit 1
fi

echo "==========================================================================="
echo "starting process..."

SOURCEPATH="$1"
STEPDIRPREFIX="$2"
NUMBEROFSTEPS=$3
OUTPUTFOLDER="$4"
REPOURL="$5"

echo ""
echo "   SOURCEPATH: $SOURCEPATH"
echo "STEPDIRPREFIX: $STEPDIRPREFIX"
echo "NUMBEROFSTEPS: $NUMBEROFSTEPS"
echo " OUTPUTFOLDER: $OUTPUTFOLDER"
echo ""

# destroy existing directory/repo if necessary
if [ -e $OUTPUTFOLDER ] ; then
	echo "removing existing output directory $OUTPUTFOLDER"
	rm -rf $OUTPUTFOLDER
fi

# make new directory
echo "creating new output directory $OUTPUTFOLDER"
mkdir $OUTPUTFOLDER

# shift to new directory
echo "shifting to output directory $OUTPUTFOLDER"
cd $OUTPUTFOLDER

# create src folder
echo "creating src folder"
mkdir src

# create test folder
echo "creating test folder"
mkdir test

# create .idea folder
echo "creating .idea folder"
mkdir .idea

# create empty repo
echo "initializing git repository"
git init

# copy repo README.md file master
echo "copying ../$SOURCEPATH/README.md to output"
cp ../$SOURCEPATH/README.md .

# add README.md file to repo and commit
echo "adding README.md file to repo for initial commit"
git add .
echo "initial commit to repo for $SOURCEPATH"
git commit -m "initial commit of README.md file for repo"

echo "pushing initial commit to $REPOURL"
git remote add origin $REPOURL
git push -u origin master

# copy files and create branches

echo "Starting subproject loop..."
STEPCOUNT=1
while [ $STEPCOUNT -le $NUMBEROFSTEPS ] ; do

  # track progress
  echo "--creating branch STEP-$STEPCOUNT"

	# start branch for step
	git branch STEP-$STEPCOUNT
	git checkout STEP-$STEPCOUNT

	# copy files for step
	echo "--copying source files from ../$SOURCEPATH/$STEPDIRPREFIX$STEPCOUNT/src/"
	cp ../$SOURCEPATH/$STEPDIRPREFIX$STEPCOUNT/src/* ./src

	echo "--copying test files from ../$SOURCEPATH/$STEPDIRPREFIX$STEPCOUNT/test/"
	cp ../$SOURCEPATH/$STEPDIRPREFIX$STEPCOUNT/test/* ./test

	echo "--copying .iml file from ../$SOURCEPATH/$STEPDIRPREFIX$STEPCOUNT/"
	cp ../$SOURCEPATH/$STEPDIRPREFIX$STEPCOUNT/*.iml .

	# copy .idea files for project, except workspace.xml
	echo "--copying .idea files from ../$SOURCEPATH/$STEPDIRPREFIX$STEPCOUNT/.idea/"
	cp ../$SOURCEPATH/$STEPDIRPREFIX$STEPCOUNT/.idea/* ./.idea

	# remove the workspace.xml file
	echo "--removing workspace.xml file"
	rm ./.idea/workspace.xml

	# add to branches
	echo "--adding copied files to current branch (STEP-$STEPCOUNT)"
	git add .

	# commit to branch
	echo "--committing files in branch for step $STEPCOUNT"
	git commit -m "added files for step $STEPCOUNT"

  # merge with master (but keep branch, don't delete)
  echo "--merging STEP-$STEPCOUNT branch with master"
  git checkout master
  git merge --no-ff -m "adding STEP-$STEPCOUNT branch" STEP-$STEPCOUNT

  echo "--step branch processing complete, setting up for next step"
  STEPCOUNT=`expr $STEPCOUNT '+' 1`

done
echo "...subproject loop completed"

echo "pushing all branches..."
git push $REPOURL '*:*'

echo "...push completed. Please check remote report for all branches"

# return to start directory
echo "shifting back to origin directory"
cd ..

# done - upload to github/bitbucket/etc manually for now
echo "done creating $OUTPUTFOLDER repo"
echo "...process completed."
echo "==========================================================================="

