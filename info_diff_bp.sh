#!/bin/bash
# Takes two revision in argument, and for each commit in between extract from
# the commit log which contains the original sha1 commit from which it was
# cherry-picked.
# It then copy modified files of the commit into a temp dir and diff with the
# same files from the original commit, and save the diff to a file

# Return the cherry picked commit of the specified commit.
# Cherrypicked commit has been indicated in commit log
function get_cherry()
{
  local rev=$1
  git log -1 ${rev} | grep "Manual Cherry pick of" | sed 's/.*Manual Cherry pick of //'
}

# Return list of files modified by commit
function get_fl_commit()
{
  local rev=$1
  git log -1 --name-status --pretty=format:"" ${rev} | sed 's/^.*\t//'
}

# Put list of files at a given commit into a temporary directory
# arg1: commit revision
# arg+: list of files
# return directory where files have been put
function get_files_at_rev()
{
  local rev=$1
  shift
  local files=$@
  local dir=$(mktemp -d)
  for f in $files; do
    mkdir -p $(dirname ${dir}/${f})
    git show ${rev}:${f} > ${dir}/${f}
  done
  echo ${dir}
}

function get_commit_list()
{
  local rev1=$1
  local rev2=$2
  # there is no new line at end of file, make sure to add one, reverse and remove empty line
  echo -e "$(git logd ${rev1}..${rev2} --pretty=format:%h)\n" | tac | sed '/^\s*$/d'
}

REV1=$1
REV2=$2
COMMIT_LIST=$(get_commit_list ${REV1} ${REV2})
for commit in ${COMMIT_LIST}; do
  cherry=$(get_cherry ${commit})
  echo "Commit: ${commit} - Cherry: ${cherry}"
  files=$(get_fl_commit ${commit})
  dir_cherry=$(get_files_at_rev ${cherry} ${files})
  dir_commit=$(get_files_at_rev ${commit} ${files})
  diff -U 2 -r ${dir_cherry} ${dir_commit} > ${cherry}.diff
  rm -Rf ${dir_cherry} ${dir_commit}
done
