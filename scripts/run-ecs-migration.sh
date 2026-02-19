#!/usr/bin/env bash
# Roda a migration Alembic (alembic upgrade head) via uma task ECS one-off.
# Uso: ENV=dev CLUSTER=<cluster-name> TASKDEF=<task-def-name> ./scripts/run-ecs-migration.sh
# Ou com AWS profile: AWS_PROFILE=myprofile ENV=dev CLUSTER=... TASKDEF=... ./scripts/run-ecs-migration.sh
set -euo pipefail

ENV="${ENV:-dev}"
CLUSTER="${CLUSTER:?Defina CLUSTER (ex: tf-aws-fullstack-dev-cluster)}"
TASKDEF="${TASKDEF:?Defina TASKDEF (ex: tf-aws-fullstack-dev-backend)}"

VPC_ID=$(aws ec2 describe-vpcs \
  --filters "Name=tag:Project,Values=tf-aws-fullstack" "Name=tag:Environment,Values=$ENV" \
  --query "Vpcs[0].VpcId" --output text)

if [ "$VPC_ID" = "None" ] || [ -z "$VPC_ID" ]; then
  echo "VPC não encontrada para env=$ENV (tags Project/Environment)."
  exit 1
fi

SUBNETS_JSON=$(aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Tier,Values=private-app" \
  --query "Subnets[].SubnetId" --output json)

if [ "$SUBNETS_JSON" = "[]" ] || [ -z "$SUBNETS_JSON" ]; then
  echo "Nenhuma subnet privada de app encontrada (tag Tier=private-app)."
  exit 1
fi

SG_ID=$(aws ec2 describe-security-groups \
  --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=tf-aws-fullstack-$ENV-ecs-sg" \
  --query "SecurityGroups[0].GroupId" --output text)

if [ "$SG_ID" = "None" ] || [ -z "$SG_ID" ]; then
  echo "Security Group ECS não encontrado (tag Name=tf-aws-fullstack-$ENV-ecs-sg)."
  exit 1
fi

echo "Subindo task de migration no cluster $CLUSTER..."
TASK_ARN=$(aws ecs run-task \
  --cluster "$CLUSTER" \
  --task-definition "$TASKDEF" \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=$SUBNETS_JSON,securityGroups=[\"$SG_ID\"],assignPublicIp=DISABLED}" \
  --overrides '{"containerOverrides":[{"name":"backend","command":["alembic","upgrade","head"]}]}' \
  --query 'tasks[0].taskArn' --output text)

echo "Task: $TASK_ARN — aguardando conclusão..."
aws ecs wait tasks-stopped --cluster "$CLUSTER" --tasks "$TASK_ARN"

EXIT_CODE=$(aws ecs describe-tasks --cluster "$CLUSTER" --tasks "$TASK_ARN" --query 'tasks[0].containers[0].exitCode' --output text)
if [ "$EXIT_CODE" != "0" ]; then
  echo "Migration falhou (exitCode=$EXIT_CODE). Verifique os logs no CloudWatch: /ecs/tf-aws-fullstack-$ENV/backend"
  exit 1
fi
echo "Migration concluída com sucesso."
