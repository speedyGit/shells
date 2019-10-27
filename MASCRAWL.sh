# Crawl Your Cohort By Roman  Jordan, Who is activly seeking a remote or in office development roll


#Declare the Repo 
repoName=$1

#Throttle Jobs
if [ $2 ]; then
  jobs=$2
else
  #Default Parallel Jobs
  jobs=15
fi

#Map OVER ALL USERS IN gitUsers.txt
mapfile -t myArray < gitUsers.txt

#Define Expected Shell Path
dir=/home/reactjscode/www/_shells

#Define Where Repos Go
repoRoot=$dir/repos/$repoName

#Include Template Files. 
[[ ! -d "$repoRoot" ]] && mkdir $repoRoot
[[ ! -f "$repoRoot/index.php" ]] && cp ./templates/_repoBrowser.php $repoRoot/index.php

#USE GNU parallel to Crawl And build All Repos
while IFS= read -r line; do
	parallel -j 15 ./gitCrawl.sh $repoName
done < gitUsers.txt































