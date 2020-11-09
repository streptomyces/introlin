# $$ contains the PID of the current shell.

### dirs -p and dirs -v

# (( )) numeric conditional
# [[ ]] logical conditional

if (( 2 - 3 )); then
  echo expression evaluated to non-zero;
  else
    echo expression evaluated to zero;
fi

if [[ -d stuffed ]]; then
  echo stuffed exists and is a directory;
  else
    echo stuffed does not exist or is not a directory;
fi


v1=a; v2=b;
if [[ $v2 > $v1 ]]; then
  echo $v2 is greater than $v1.;
  elif [[ $v2 < $v1 ]]; then
  echo $v2 is less  than $v2.;
fi

v1=80; v2=70;
if (( $v2 > $v1 )); then
  echo $v2 is greater than $v1.;
  elif (( $v2 < $v1 )); then
  echo $v2 is less than $v1.;
fi

echo 'All kinds \n of $pecial characters';


# Combining stdout and stderr.
./outanderr.pl | less
./outanderr.pl |& less
# How do we pipe just the stderr?


# Shell functions are executed in the context of the current shell.

declare -x -f lslhtr
declare -x -f testfun

function lslhtr {
ls -lhtr
}

function testfun {
echo $$;
echo $PPID;
#testal
lslhtr;
}

export -f lslhtr
export -f testfun

{ ./script.bash; }


# looping while and for
# (not finished).
declare -i cnt=10;
echo $cnt;
while (( $cnt >= 1  )); do
echo $cnt;
: $(( cnt-- ));
done

alias testal="ls ~";

# Shell parameters.

# Name     Number    Special

# Special parameters

echo $0 # Name of shell or shell script.
echo $@ # Arguments
echo $* # Arguments
echo $? # Exit status of the most recent pipeline.

var1=stuff
unset var1;
echo $var1;
echo ${var1};

### exclude ###
# echo ${var1:-something} # Don't include this.
# echo ${var1:=something}
# unset var;
# unset var1;
# echo ${var1:?var1 does not exist}

# Arrays

unset names;
declare -a names;
names=([1]=one [3]=two [2]=three four five six);
echo ${names[@]}

names=([6]=seven);
echo ${names[@]}
# Below is what you can do to start your array index from 1.

somearray=([1]=one two three four five six seven eight);
echo ${somearray[@]}
echo ${somearray[1]}
echo ${somearray[8]}

unset somearray;
echo ${somearray[@]}
somearray=stuff;
somearray[3]=stuff2;
echo ${somearray[@]}
echo ${somearray[0]}
echo ${somearray[1]}
echo ${somearray[2]}
echo ${somearray[3]}

# Associative arrays

declare -A hash
hash=([one]=ten [two]=twenty [three]=thirty);
echo ${hash[@]}
echo ${hash[one]}


com="ls";
echo $($com);

./outanderr.pl > out 2>&1
./outanderr.pl 2>&1 > out1


exec 6< ../introlin/test
declare -ax avc
mapfile -u 6 avc
exec 6>&-
exec 6<&-

unset avc
declare -ax avc
# cat ../introlin/test | mapfile avc
# mapfile avc < <(cat ../introlin/test)
mapfile avc < ../introlin/test
echo ${avc[3]}
#;

coproc CP {
  echo
}
echo ${CP[1]}
echo ${CP[0]}

echo stuffed >&"${CP[1]}"
read cpout <&"${CP[0]}"
echo $cpout
#;


coproc myproc {
    bash
}
# send a command to it (echo a)
echo 'echo a' >&"${myproc[1]}"
# read a line from its output
read line <&"${myproc[0]}"
# show the line
echo "$line"
#;


declare -A strcnt
strcntwc -l < <(awk '$1 ~/mutant2/ {print $0}' ../introlin/test)


twit () {
  while read input
    do
      echo $input $input
    done
}
declare -fx twit

yes | twit

bd=file.txt; ([[ -d $bd ]] && ls $bd/bldb) || ([[ -f $bd ]] && head $bd)
