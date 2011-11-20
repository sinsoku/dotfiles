#!bash
#
# version: 0.2
# license: New BSD License
#
# how to install
# ===============
#
# * Ubuntu
# $ cp git_cd.bash /etc/bash_completion.d/git_cd

_git_cd()
{
    if [ ${COMP_CWORD} -lt 2 ]; then
        git_root="`git rev-parse --git-dir 2>/dev/null`/../"
        ret=$?
        if [ ${ret} -ne 0 ]; then return 0; fi

        cur="${COMP_WORDS[COMP_CWORD]}"
        dist="${git_root}${cur}"
        if [ -d "${dist}" ]; then
            opts="`ls -a ${dist}`"
        else
            opts="`ls -a ${git_root}`"
        fi

        COMPREPLY=( ${opts} )
    fi
}
complete -F _git_cd git_cd
complete -F _git_cd gcd
