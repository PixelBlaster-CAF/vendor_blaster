function __print_blaster_functions_help() {
cat <<EOF
Additional Paranoid Android functions:
- cafmerge:        Utility to merge CAF tags.
- repopick:        Utility to fetch changes from Gerrit.
EOF
}

function cafmerge()
{
    target_branch=$1
    set_stuff_for_environment
    T=$(gettop)
    python3 $T/vendor/blaster/build/tools/merge-caf.py $target_branch
}

function repopick()
{
    T=$(gettop)
    $T/vendor/blaster/build/tools/repopick.py $@
}

export SKIP_ABI_CHECKS="true"

# Enable global ThinLTO
#
# This doesn't increase build time significantly, so enable it for
# performance.
export GLOBAL_THINLTO=true