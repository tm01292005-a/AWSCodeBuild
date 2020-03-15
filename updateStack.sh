#!/bin/bash

###############################################################################
### Variable                                                                ###
###############################################################################
# MicroServiceName.
CODEBUILD_PROJECTS=('My' 'You')
REGION='--region ap-northeast-1'
DATETIME=$(date "+%Y%m%d%H%M%S")
CHANGE_SET_NAME="CHANGESET-$DATETIME"
ENV=''
OPT_TEMPLATE=''
PARAM_YAML="param_${DATETIME}.yaml"


###############################################################################
### Func: Usage & Exit.                                                     ###
###############################################################################
usage_exit() {
    echo "Usage: $(basename "$0") -e environment [-t template-path]
    "
        echo "Where:
        -e environment     - Environment. [ a | b | c | d ]
        -t template-path   - CloudFormation template file path.
    "
        echo "Example:
        1) sh $(basename "$0") -e a -t lambda_temp
        2) sh $(basename "$0") -e b 
    "
    exit_task 1
}


###############################################################################
### Func: Exit Task.                                                        ###
###############################################################################
exit_task() {
     if [[ -f ${PARAM_YAML} ]]; then
         rm -f ${PARAM_YAML} 2>/dev/null
     fi
     
     exit $1
}


###############################################################################
### Func: Describe CloudFormation.                                          ###
###############################################################################
describe_cfn() {
    aws cloudformation describe-stacks $REGION \
        --stack-name $STACK_NAME \
        --output yaml > ./$1/${DATETIME}_${ENV}_${STACK_NAME}_cfn_stack.yaml

    aws cloudformation get-template $REGION \
        --stack-name $STACK_NAME \
        --query 'TemplateBody' \
        --output yaml > ./$1/${DATETIME}_${ENV}_${STACK_NAME}_cfn_template.yaml
}


###############################################################################
### Func: Describe CodeBuild.                                               ###
###############################################################################
describe_codebuild() {
    for PROJECT in ${CODEBUILD_PROJECTS[@]}
    do
        aws codebuild batch-get-projects $REGION \
            --names ${PROJECT}TestBuild \
            --output yaml > ./$1/${DATETIME}_${ENV}_${PROJECT}_codebuild.yaml
    done
}


###############################################################################
### Func: Generate CloudFormation Parameter Yaml File.                      ###
###############################################################################
generate_param_yaml() {
    echo "# STACK_NAME: ${STACK_NAME}" > ./${PARAM_YAML}
    echo "# パラメータの値を変更する場合はParameterValueを書き換えて保存後、" >> ./${PARAM_YAML}
    echo "# テキストを閉じてください。" >> ./${PARAM_YAML}
    echo "# 何も変更しない場合はそのままテキストを閉じてください。" >> ./${PARAM_YAML}
    echo "Parameters: " >> ./${PARAM_YAML}
    aws cloudformation describe-stacks $REGION \
        --stack-name $STACK_NAME \
        --query "Stacks[0].Parameters" \
        --output yaml  >> ./${PARAM_YAML}
}


###############################################################################
### Func: ASK.                                                              ###
###############################################################################
ask_yes_no() {
    while true; do
        echo -n "$* [y/n]: "
        read ANS
        case $ANS in
             [Yy]*) return 0 ;;  
             [Nn]*) return 1 ;;
             *) ;;
        esac
    done
}


###############################################################################
### Main                                                                    ###
###############################################################################

# Check Option.
count=0
while getopts "e:t:" OPT
do
    case $OPT in
        e)  count=`expr $count + 1`
            ENV=$OPTARG
            case $OPTARG in
                a) STACK_NAME='test-pipeline' ;;
                b) STACK_NAME='java-lambda' ;;
                c) STACK_NAME='lambdatest' ;;
                d) STACK_NAME='awscodestar-test-spring' ;;
                *) usage_exit ;;
            esac
            ;;
        t)  count=`expr $count + 1`
            OPT_TEMPLATE=" --template-body file://${OPTARG}" 
            ;;
        *)  usage_exit ;;
    esac
done
if [ $count -lt 1 ]; then 
    usage_exit
fi 

echo "ENVIRONMENT    : $ENV"
echo "STACK_NAME     : $STACK_NAME"
echo "CHANGE_SET_NAME: $CHANGE_SET_NAME"
echo ""

# Check Cloudformation Template.
if [ "$OPT_TEMPLATE" != "" ]; then
    echo "***Check Cloudformation Template.***"
    MESSAGE=$(aws cloudformation validate-template $REGION $OPT_TEMPLATE 2>&1 > /dev/null)
    if [ $? -ne 0 ] ; then
        echo "=>Failed. Reason=$MESSAGE"
        exit_task 1;
    fi
    echo "=>Success."
else
    OPT_TEMPLATE="--use-previous-template"
fi

# Get Before Cloudformation/CodeBuild Info.
echo "***Get Before Cloudformation/CodeBuild Info.***"
mkdir -p ./before 2>/dev/null
mkdir -p ./after 2>/dev/null
describe_cfn before
describe_codebuild before
echo "=>Success."

# Edit Cloudformation Parameter Yaml.
echo "***Edit Cloudformation Parameter Yaml.***"
generate_param_yaml
notepad ./${PARAM_YAML}
echo "=>Success."

# Create Change Set.
echo "***Create Change Set.***"
MESSAGE=$(aws cloudformation create-change-set $REGION \
            --stack-name $STACK_NAME $OPT_TEMPLATE \
            --cli-input-yaml file://${PARAM_YAML} \
            --change-set-name $CHANGE_SET_NAME \
            --capabilities CAPABILITY_IAM 2>&1 > /dev/null)
if [ $? -ne 0 ] ; then
    echo "=>Failed. Reason=$MESSAGE"
    exit_task 1;
fi
echo "=>Success."

# Wait until change set status is CREATE_COMPLETE.
echo "***Wait until change set status is CREATE_COMPLETE.***"
MESSAGE=$(aws cloudformation wait change-set-create-complete $REGION \
            --stack-name $STACK_NAME \
            --change-set-name $CHANGE_SET_NAME 2>&1 > /dev/null)
if [ $? -ne 0 ] ; then
    MESSAGE=$(aws cloudformation describe-change-set $REGION \
                --stack-name $STACK_NAME \
                --change-set-name $CHANGE_SET_NAME \
                --query "StatusReason")

    aws cloudformation delete-change-set $REGION \
        --stack-name $STACK_NAME \
        --change-set-name $CHANGE_SET_NAME
    echo "=>Failed. Reason=$MESSAGE"
    exit_task 1;
fi
echo "=>Success."

# Describe Update Info.
MESSAGE=$(aws cloudformation describe-change-set $REGION \
    --stack-name $STACK_NAME \
    --change-set-name $CHANGE_SET_NAME \
    --query 'Changes[].ResourceChange.{"1.Action":Action,"2.ResourceType":ResourceType,"3.Resource":PhysicalResourceId,"4.Environment":join(`,`,Details[].CausingEntity)}' \
    --output table)
echo -e "$MESSAGE"

MESSAGE=$(aws cloudformation describe-change-set $REGION \
    --stack-name $STACK_NAME \
    --change-set-name $CHANGE_SET_NAME \
    --query 'Parameters' \
    --output table)
echo -e "$MESSAGE"

# Ask Update Stack.
if ask_yes_no "Update Stack OK?"; then
    echo "***Updates the specified change set.***"
    MESSAGE=$(aws cloudformation execute-change-set $REGION \
                --stack-name $STACK_NAME \
                --change-set-name $CHANGE_SET_NAME)
else
    echo "***Deletes the specified change set.***"
    MESSAGE=$(aws cloudformation delete-change-set $REGION \
                --stack-name $STACK_NAME \
                --change-set-name $CHANGE_SET_NAME)
    echo "=>Success."
    exit_task 0;
fi

# Waiting for stack update to complete.
echo "***Waiting for stack update to complete.***"
MESSAGE=$(aws cloudformation wait stack-update-complete $REGION \
            --stack-name $STACK_NAME 2>&1 > /dev/null)
if [ $? -ne 0 ] ; then
    MESSAGE=$(aws cloudformation describe-stack-events $REGION \
                --stack-name $STACK_NAME \
                --query 'StackEvents[?ResourceStatus==`UPDATE_FAILED`].ResourceStatusReason')
    echo "=>Failed. Reason=$MESSAGE"
    exit_task 1;
fi
echo "=>Success."

# Get After Cloudformation/CodeBuild Info.
echo "***Get After Cloudformation/CodeBuild Info.***"
describe_cfn after
describe_codebuild after
echo "=>Success."

exit_task 0
