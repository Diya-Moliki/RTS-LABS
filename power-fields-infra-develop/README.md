# powerfields-infra

## Developing
We follow typical git flow, starting on `develop` and eventually merging into `master` when changes go into production. We have decided to follow this pattern to protect higher environments being affected by changes being tested in lower environments and so changes are thoroughly applied in all environments.

### To work on typical new feature
1. Create a new feature branch from `develop`
2. Make your modifications to the `master` *folder* and `live` folder if necessary
3. If any changes are required in the `live/**` directories, be sure to make them for all environments. This will help:
    * quicker code promotions and releases
    * nothing is during the release potentially weeks later
    * the same person is able to do all the required changes
4. While developing, try to restrict running `terragrunt apply` in:
    * `live/nonprod/app/dev/**`
5. Once you have applied your changes to dev and are satisfied, create a pull request
6. Once PR is approved, merge to develop (changes should already be applied to dev)
7. On next QA release (or one scheduled specifically for devops change), merge into `qa` and update resources in `live/nonprod/app/qa` and below
8. Repeat the last step but for `perf`, `uat`, `demo`, and eventually `master`
    * If you have changes that affect all non-prod environments, wait to run these changes until merged into `uat` (see below)

It may be required that you initially branch off `master` if you expect your feature to escalate faster than other changes.

### Nonprod-wide only feature
Some changes only affect resources that are shared between all non-prod environments, e.g. applying in `live/nonprod` directly. These changes should follow this pattern:
1. Create a new feature branch from `uat`
2. Make your modifications to the `master` *folder* and `live` folder if necessary
3. Only use `terraform plan` locally
4. If any changes are required in the `live` directory, be sure to make them for all environments.
5. Create a pull request
6. Once PR is approved, merge into `uat` and `apply` your changes *during a scheduled release*
7. Merge `uat` into all lower branches, e.g. `develop`, `qa`, and `perf`
8. During the next production release, merge into `master` and `apply` there

### Secrets
todo - probably through secrets manager

## Adding Non-prod env
1. Copy the directory of the level below, probably uat
2. Delete the `.terraform` directory
3. Replace all `uat` with new env name
4. Follow the steps in that directories `README.md` to add a client
5. Build the branch of the new env in jenkins, so it publishes to ECR (note it will fail to deploy app)
6. Run the following in the new env terraform directory:
```bash
terraform init
terraform apply -target aws_acm_certificate.cert
terraform apply
```
(the last command may need to be run several times)
6. Wait for app to start
7. Create a super admin (username `password`):
```sql
insert into pf_user (id, created_by, created_date, last_modified_by, last_modified_date, email, password_hash,
                     first_name, last_name, auth_provider_type, status)
values (nextval('sequence_generator'), 'manual', now(), 'manual', now(), 'superadmin1@powerfields.io',
        '$2a$10$Ei2yXyT8YAyG9PbfjIZImOCeNjRbzoNMqGt.vHqtma5zklfiX0D4.', 'Super', 'Admin', 'local', 'ACTIVE');
INSERT INTO pf_user_authority (user_id, authority_name)
VALUES ((select id from pf_user where email = 'superadmin1@powerfields.io'), 'ROLE_SUPER_ADMIN');
```
# To Add Non-Prod Client
First, create some data:
 * Database name: typically `powerfields_<env>_<client>_app`
 * Database username: typically `<database_name>_user`
 * Database password: Do we have requirements around this?
 * Token secret: Run `openssl rand -base64 128` and put on one line
 
 
####_Set up SSM Parameters_
Upload the database parameters:
```
aws --profile powerfields-dev ssm put-parameter --type "SecureString" \
    --name "/<env>/<client>/<app>/rds/username" --value "<database username from above>"

aws --profile powerfields-dev ssm put-parameter --type "SecureString" \
    --name "/<env>/<client>/<app>/rds/password" --value "<database password from above>"
```

Upload the token secrete from above:
```
aws --profile powerfields-dev ssm put-parameter --type "SecureString" \
    --name "/<env>/<client>/<app>/jhipster/jwt/secret" --value "<token secret from above>"
```

Upload the keystore information. Get these values from other clients.
```
aws --profile powerfields-dev ssm put-parameter --type "SecureString" \
    --name "/<env>/<client>/<app>/app/keystore/password" --value "<value>"

aws --profile powerfields-dev ssm put-parameter --type "SecureString" \
    --name "/<env>/<client>/<app>/app/keystore/key_password" --value "<value>"
```
You would hope you could do this all from the CLI, but you would be wrong! The cli actually tries to GET a value of a URL
so you need to upload this one manually: `/<env>/<client>/<app>/app/keystore/location`


####_Set up database_
Log into a database on the shared dev database (anyone will do) and run the following:
```postgresql
create database <database name from above>;
create user <database username from above> with encrypted password '<password from above>';
grant all privileges on database <database name from above> to <database username from above>;
```
Once the database has been created, log onto it as an admin (shrdbadev) and run the following:

```postgresql
create extension postgis;
create extension fuzzystrmatch;
create extension postgis_tiger_geocoder;
create extension postgis_topology;

alter schema tiger owner to rds_superuser;
alter schema tiger_data owner to rds_superuser;
alter schema topology owner to rds_superuser;


CREATE FUNCTION exec(text) returns text language plpgsql volatile AS $f$ BEGIN EXECUTE $1; RETURN $1; END; $f$;


SELECT exec('ALTER TABLE ' || quote_ident(s.nspname) || '.' || quote_ident(s.relname) || ' OWNER TO rds_superuser;')
FROM (
         SELECT nspname, relname
         FROM pg_class c JOIN pg_namespace n ON (c.relnamespace = n.oid)
         WHERE nspname in ('tiger','topology') AND
                 relkind IN ('r','S','v') ORDER BY relkind = 'S')
         s;

SET search_path=public,tiger;
```
TODO - automate above


####_Set up terraform_
Create the terragrunt files following these steps:
 * Copy a similar client in `terraform/live/global` and update the ecr `prefix`
 * Copy a similar client in the same environment, e.g in `/terraform/live/nonprod/app/dev`
 * Update the `TENANT` in `.envrc` - KEEP IT SHORT
 * In `main.hcl`
     * Update `application_name` - KEEP IT SHORT
     * Update `prefix` - KEEP IT SHORT
     * Update `Application` in tags
 * In `ecs_service`, update the ECR config path
 * In `sqs` update the prefix
 
Then run all the terragrunt: 
 * Before `ecs_service`, disable mfa_delete and see https://github.com/rtslabs/power-fields-infra/wiki/S3-additional-safeguards

# Setting up prod

## Manual Steps
1. Generate two key pairs: https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#KeyPairs: 
"powerfields-prod-devops" and "powerfields-prod-ecs"

# Clean up
The `.terragrunt-cache` folders end up using a lot of space. To delete them: 
`find . -type d -name .terragrunt-cache -prune -exec rm -rf {} \;`


# misc todo
 * Change `client_app_variables` to a list instead of a map
 * Create all client specific `frontend` and `templates`
