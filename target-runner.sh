# File to write the execution output
STDOUT=c${CONFIG_ID}-${INSTANCE_ID}-${SEED}.stdout
STDERR=c${CONFIG_ID}-${INSTANCE_ID}-${SEED}.stderr

# Check if executable exists
if [ ! -x "${EXE}" ]; then
    error "${EXE}: not found or not executable (pwd: $(pwd))"
fi

# Now we can call ACOTSP by building a command line with all parameters for it
$EXE ${FIXED_PARAMS} -i $INSTANCE --seed $SEED ${CONFIG_PARAMS} 1> $STDOUT 2> $STDERR

# The output of the candidate $CONFIG_ID should be written in the file 
# c${CONFIG_ID}.stdout (see target runner for ACOTSP).
# Does this file exist?
if [ ! -s "${STDOUT}" ]; then
    # In this case, the file does not exist. Let's exit with a value 
    # different from 0. In this case irace will stop with an error.
    error "${STDOUT}: No such file or directory"
fi

# Ok, the file exist. It contains the whole output written by ACOTSP.
# This script should return a single numerical value, the best objective 
# value found by this run of ACOTSP. The following line is to extract
# this value from the file containing ACOTSP output.
COST=$(cat ${STDOUT} | grep -o -E 'Best [-+0-9.e]+' | cut -d ' ' -f2)
if ! [[ "$COST" =~ ^[-+0-9.e]+$ ]] ; then
    error "${STDOUT}: Output is not a number"
fi

# Print it!
echo "$COST"

# We are done with our duty. Clean files and exit with 0 (no error).
rm -f "${STDOUT}" "${STDERR}"
rm -f best.* stat.* cmp.*
exit 0
