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
        git_repo="`git rev-parse --git-dir 2>/dev/null`"
        ret=$?
        if [ ${ret} -ne 0 ]; then return 0; fi
        if [ "${git_repo}" == ".git" ]; then
            git_root="`pwd`/"
        else
            git_root="${git_repo%.git}"
        fi

        cur="${COMP_WORDS[COMP_CWORD]}"
        if [ -n "${cur##*/}" ]; then
            cur_d="${cur}/"
        else
            cur_d="${cur}"
        fi

        dist="${git_root}${cur_d}"
        if [ -d "${dist}" ]; then
            subs=`compgen -d "${dist}"`
            opts=`for s in ${subs}; do echo ${s#${git_root}}; done`
        else
            subs=`compgen -d "${dist%/[^/]*}/"`
            opts=`for s in ${subs}; do echo ${s#${git_root}}; done`
        fi

        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    fi
}
complete -F _git_cd git_cd
complete -F _git_cd gcd
