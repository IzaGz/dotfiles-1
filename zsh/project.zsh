export CODEPATH=~/code

function projectName() {
  if [[ "$1" != "" ]]; then
    project="$1"
  else
    project=`pwd`
  fi
  name=${project##$CODEPATH/src/github.com/}

  if [[ $name = /* ]]; then
    echo "N/A"
  else
    echo $name
  fi
}

function project() {
  me=dmathieu
  users=($(ls $CODEPATH/src/github.com))

  if [[ $1 =~ .*/.* ]]; then
    users=(${1[(ws:/:)1]})
    name=${1[(ws:/:)2]}
  else
    name=$1
  fi

  if [[ $* == *\ -n* ]]; then
    if [[ ${#users[@]} > 1 ]]; then
      user=$me
    else
      user=$users
    fi

    dir=$CODEPATH"/src/github.com/"$user"/"$name

    echo "Initializing new project "$user"/"$name
    mkdir $dir
    cd $dir
    git init

    return
  fi

  for user in $users; do
    dir=$CODEPATH"/src/github.com/"$user"/"$name

    if [[ -d $dir ]]; then
      cd $dir

      if [[ $* != *\ -s* ]]; then
        git checkout master
        gclean
      fi

      return
    fi
  done

  for user in $users; do
    apiUri="https://api.github.com/repos/"$user"/"$name
    gitUri="https://github.com/"$user"/"$name".git"
    code=`curl -n -o /dev/null --silent --head --write-out '%{http_code}\n' $apiUri`

    if [[ $code == 200 ]]; then
      dir=$CODEPATH"/src/github.com/"$user"/"$name
      git clone $gitUri $dir
      cd $dir
      return
    fi
  done

  echo "Couldn't find any project '$1'. Did you mistype it?"
}


alias p="project"
