
gdb_screen()
{
    prog=$1
    shift
    IFS=
    name=${*/-/}
    IFS=' '
    screen -S :$name -d -m bash -l -c "echo $*; echo $LIBRARY_PATH; gdb $prog -ex \"run $*\""
}

lldb_screen()
{
    prog=$1
    shift
    IFS=
    name=${*/-/}
    IFS=' '
    echo debug $prog with arguments $*
    echo name: $name
    tmp=/tmp/$RANDOM
    echo run > $tmp
    screen -S :$i -d -m bash -l -c "lldb -s $tmp $prog -- $*"
}

run_player() {
    port=${PORT:-$((RANDOM%10000+10000))}
    bin=$1
    shift
    prog=$1
    prog=${prog##*/}
    prog=${prog%.sch}
    shift
    if ! test -e $SPDZROOT/logs; then
        mkdir $SPDZROOT/logs
    fi
    params="$prog $* -pn $port -h localhost -P 304965283352184400401410545793169118303"
    if $SPDZROOT/$bin 2>&1 | grep -q '^-N,'; then
       params="$params -N $players"
    fi
    if test "$prog"; then
	log_prefix=$prog-
    fi
    set -o pipefail
    for i in $(seq 0 $[players-1]); do
      >&2 echo Running $prefix $SPDZROOT/$bin $i $params
      log=$SPDZROOT/logs/$log_prefix$i
      $prefix $SPDZROOT/$bin $i $params 2>&1 |
	  { if test $i = 0; then tee $log; else cat > $log; fi; } &
      codes[$i]=$!
    done
    for i in $(seq 0 $[players-1]); do
	wait ${codes[$i]} || return 1
    done
}

players=${PLAYERS:-2}

SPDZROOT=${SPDZROOT:-.}
