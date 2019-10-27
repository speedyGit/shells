#Vars
home=$(pwd)

gitRepo=$1
gitUser=$2

dir=/home/reactjscode/public_html/repos
repoRoot=$dir/$gitRepo

#expectedPath
expctPth=$repoRoot/$gitUser/$gitRepo
buildPth=$repoRoot/$gitUser

if [ $gitRepo ] && [ $gitUser ]
then
    #IF PATH UPDATE ELSE CREATE
    if [ -d $expctPth ] && [ -d "$expctPth/.git" ] ; then
        #Enter The Path
        cd $expctPth
	
	git pull --all
        for b in `git branch -r | grep -v -- '->'`; do
            if [ $b == origin/solution ] || [ $b == origin/ryan-solution ] || [ $b == origin/master ] 
                then
		    echo unmergeable  
		else
                    git merge $b
                fi
        done
        # Check For Server File DEPLOY SEVER FILE TO CEBERUS/TRACK/REPO  Maybe abstract out
        if [ -f "package.json" ] && [ ! -f "server.js" ]; then
		#Clean Up The Repo To Use PNPI
		[[ -f "package-lock.json" ]] && rm -rf ./package-lock.json
                [[ -f "yarn.lock" ]] && rm -rf ./yarn.lock

		#Set Base URL where app will live
		find ./src -type f -exec sed -i 's+http://localhost:5000+https://api.reactjscode.com+g' {} +
                [[ ! -f ".env" ]] && echo PUBLIC_URL=https://reactjscode.com/_shells/repos/$gitRepo/$gitUser/build/ > ./.env
		
		#Build
		pnpm i
		npm run-script build
	        
		#Add Build Filure Note HERE
		#TBC
		
		#Remove Existing Build Folder
                [[ -d "$buildPth/build" ]] && rm -rf $buildPth/build
		
		#Move New Build Project Root
                [[ -d "build/" ]] && mv -f ./build/ $buildPth
		
		#Link Template File
                [[ ! -f "$buildPth/index.php" ]] && cp $home/nueron.php $buildPth/index.php
        else 
		#This Could Lead to some problems
		#Searhes for React App and Trys to Build from Project Root
		for d in */; do
       		  if [ -f "$d/package.json" ] && [ -d "$d/src" ]
		  then
			cd $d
			#Build app if it was found
			find ./src -type f -exec sed -i 's+http://localhost:5000+https://api.reactjscode.com+g' {} + 
        		pnpm i
			npm run-script build
	
			#Move New Build To Project Root
			[[ -d "$buildPth/build" ]] &&  rm -rf $buildPth/build
			[[ -d "./build/" ]] && mv -f ./build/ $buildPth
    		  fi
		done
	fi
    else          
	#If the App does not already Exist
        git clone https://l:l@github.com/$gitUser/$gitRepo ./
        if [ -d $expctPth ]; then
            #Enter The Repos
	    cp $home/nueron.php $buildPth/index.php
            cd $expctPth
            for b in `git branch -r | grep -v -- '->'`; do
                if [ $b == origin/solution ] || [ $b == origin/ryan-solution ] || [ $b = origin/master ]
                then
		    echo $b
		else
		    echo Merging $b
		    git merge $b
                fi
            done

            if [ -f "package.json" ] && [ ! -f "server.js" ]
            then
		[[ -f "package-lock.json" ]] && rm -rf ./package-lock.json
                [[ -f "yarn.lock" ]] && rm -rf ./yarn.lock
                echo PUBLIC_URL=https://reactjscode.com/_shells/repos/$gitRepo/$gitUser/build/ > ./.env
		find ./src -type f -exec sed -i 's+http://localhost:5000+https://api.reactjscode.com+g' {} +
                pnpm i
		npm run-script build 
                [[ -d "build/" ]] && mv -f ./build/ $buildPth
                cp -f $home/nueron.php $buildPth/index.php
	    else [ -f "package.json" ] && [ -f "server.js" ]
                for d in */; do
                  if [ -f "$d/package.json" ] && [ -d "$d/src" ]
                  then
			cd $d
			[[ -f "package-lock.json" ]] && rm -rf ./package-lock.json
	                [[ -f "yarn.lock" ]] && rm -rf ./yarn.lock
	
			find ./src -type f -exec sed -i 's+http://localhost:5000+https://api.reactjscode.com+g' {} +
			echo PUBLIC_URL=https://reactjscode.com/_shells/repos/$gitRepo/$gitUser/build/ > ./.env
			pnpm i
                        npm run-script build
                        [[ -d "./build/" ]] && mv -f ./build/ $buildPth
                  fi
                done
            fi
	else
	echo "repo does not exist" >$buildPth/index.html
        fi
    fi
fi

