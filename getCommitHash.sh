#!/bin/bash

BRANCH_NAME='master'
CODECOMMIT_REPOSITORYS=( 
    'my-repository'
    'test-spring'
)
DATETIME=$(date "+%Y%m%d%H%M%S")
OUTPUT=commithash_${DATETIME}.txt

write_to_text() {
    echo -e "$1" >> ${OUTPUT}
}

get_commit_hash() {
    declare -a hash_array=()
    for REPOSITORY in ${CODECOMMIT_REPOSITORYS[@]}
    do
        commit_hash=$(aws codecommit get-branch \
                --repository-name ${REPOSITORY} \
                --branch-name ${BRANCH_NAME} \
                --query "branch.commitId" \
                --output text 2>/dev/null)
        hash_array=("${hash_array[@]}" ${commit_hash})
    done

    # Write to text
    i=0
    for REPOSITORY in ${CODECOMMIT_REPOSITORYS[@]}
    do
        write_to_text "${REPOSITORY},${BRANCH_NAME},${commit_hash}"
        let i++
    done

    write_to_text "\r# Jira Comment Table.\r||MS ||Commit Hash||"

    i=0
    for REPOSITORY in ${CODECOMMIT_REPOSITORYS[@]}
    do
        write_to_text "|${REPOSITORY}|${hash_array[$i]}|"
        let i++
    done
}
get_commit_hash

exit 0
