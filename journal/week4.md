# Week 4 — Postgres and RDS
// Just found my week2 journal submission commit didnt go through, I'm working on it again now
### Required homework

_Create RDS Postgres Instance_

- Set env vars for master-username, master-user-password and port generated

```
export POSTGRES_MASTER_USERNAME="<my-master-username>"
gp env POSTGRES_MASTER_USERNAME=$POSTGRES_MASTER_USERNAME
export POSTGRES_MASTER_PASSWORD="<my-master-password>"
gp env POSTGRES_MASTER_PASSWORD=$POSTGRES_MASTER_PASSWORD
export POSTGRES_PORT="<my-port>"
gp env POSTGRES_PORT=$POSTGRES_PORT
```
- Created a new instance in aws rds by running:

```
$ aws rds create-db-instance \
  --db-instance-identifier cruddur-db-instance \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --engine-version  14.6 \
  --master-username ${POSTGRES_MASTER_USERNAME} \
  --master-user-password ${POSTGRES_MASTER_PASSWORD} \
  --allocated-storage 20 \
  --availability-zone "${AWS_DEFAULT_REGION}a" \
  --backup-retention-period 0 \
  --port ${POSTGRES_PORT} \
  --no-multi-az \
  --db-name cruddur \
  --storage-type gp2 \
  --publicly-accessible \
  --storage-encrypted \
  --enable-performance-insights \
  --performance-insights-retention-period 7 \
  --no-deletion-protection
```

- Exported the RDS instance endpoint to the environment

```
export PROD_DB_ENDPOINT="<my-endpoint>"
gp env PROD_DB_ENDPOINT=$PROD_DB_ENDPOINT 
export PROD_CONNECTION_URL = "postgresql://${POSTGRES_MASTER_USERNAME}:${POSTGRES_MASTER_PASSWORD}@${PROD_DB_ENDPOINT}:${POSTGRES_PORT}/cruddur"
gp env PROD_CONNECTION_URL=$PROD_CONNECTION_URL
```
- Setup local postgres env vars to the environment

```
export CONNECTION_URL="postgresql://postgres:password@localhost:5432/cruddur"
gp env CONNECTION_URL=$CONNECTION_URL

// Also can be set with

export CONNECTION_LOCAL_DOCKER_URL="postgresql://postgres:password@db:5432/cruddur"
gp env CONNECTION_LOCAL_DOCKER_URL=$CONNECTION_LOCAL_DOCKER_URL
```

_Bash scripting for database operation and SQL files_

- Wrote bash scripts in the /backend-flask/bin/ directory with each script beginning with a  #! usr/bun/bash to initialize the file as a bash script

- Gave the bash scripts execute permissions by running:
```
chmod 744 bin/db-*
```

![seededdata](./asssets/tablewithseededdata.png)

- Allow connection fromm our workspace to the aws rds instance, a script rds-update-sg-rule is created. This requires the following environment keys to be set DB_SG_RULE_ID and DB_SG_ID

_Install Postgres Driver in Backend Application and Connecting to Local RDS Instance_

- psycopg is a python adapter for interacting PostgreSQL from the Python scripting language
- Added to requirements.txt file:

```
psycopg[binary]
psycopg[pool]
```
- In the /backend-flask/lib directory, a file module called db.py is created and populated with:

```python
from psycopg_pool import ConnectionPool
import os

# Wrap query and ensure object result is returned as json
def query_wrap_object(template):
  sql = f"""
  (SELECT COALESCE(row_to_json(object_row),'{{}}'::json) FROM (
  {template}
  ) object_row);
  """
  return sql

#Wrap query and ensure array result is returned as json
def query_wrap_array(template):
  sql = f"""
  (SELECT COALESCE(array_to_json(array_agg(row_to_json(array_row))),'[]'::json) FROM (
  {template}
  ) array_row);
  """
  return sql


connection_url = os.getenv("CONNECTION_URL")
pool = ConnectionPool(connection_url)

```
- Ran docker compose up to execute the sql join

![First Join](./assets/joiningproof.png)

_Create Lambda Layer_

- Implemented a Lambda Function to trigger Cognito user pool to insert registered users to the database

```
import os
import json
import psycopg2

def lambda_handler(event, context):
    user = event['request']['userAttributes']
    user_display_name = user["name"]
    user_email = user["email"]
    user_handle = user["preferred_username"]
    user_cognito_id = user["sub"]
        
    try:
        conn = psycopg2.connect(os.getenv("CONNECTION_URL"))
        cur = conn.cursor()
        sql = f"""
        INSERT INTO public.users (
            display_name,
            email, 
            handle, 
            cognito_user_id
            ) 
        VALUES(
            %s, %s, %s, %s
            )
        """ 
        args= [
            user_display_name, 
            user_email, 
            user_handle, 
            user_cognito_id
            ]
            
        print(sql)
        cur.execute(sql, *args)
        conn.commit()
        print('Commit Done')

    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        
    finally:
        if conn is not None:
            cur.close()
            conn.close()
            print('Database connection closed.')

    return event
```

- Ensured that the lambda can make network calls, and additional policy was added to the lambda role by:

- In the Configuration -> Permissions tab, I added an addition policy to the execution role. This was done by clicking on the Role name, which then    redirects on to IAM Management console for the current lambda role. In there, the following steps were performed: Attach policies(from the Add permission dropdown) -> Create Police -> Choose a Service (Selected EC2) -> Switch editor to JSON (Click on JSON). Copied the following in it:
```JSON
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateNetworkInterface",
                "ec2:DeleteNetworkInterface",
                "ec2:DescribeNetworkInterfaces",
                "ec2:AttachNetworkInterface",
                "ec2:DescribeInstances"
            ],
            "Resource": "*"
        }
    ]
}
```
- Reviewed Policy and created Policy then attached the created policy to the Lambda role
- Inspected that the policy has been added by reviewing the policies available in the lambda function Configuration -> Permissions tab and in the     Resource summary dropdown.

_Creating New Activities with a Database insert_

- Successfully posted crudds on cruddur

![success](./assets/firstjoin.png)


