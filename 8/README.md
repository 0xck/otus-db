# Otus RDBMS study case

This is RDBMS study case. Postgresql DB and study case schema *wrex* was packed into Docker image.

> Note. Current version contains only schema not any data.

## Usage

### Requirements
Check for system has `zcat` and `docker` installed.

### Before start
1. Download directory content
2. Go to directory with downloaded content
3. Add execution permission for deploy script using command `chmod +x deploy_image.sh`

### Building and Running
#### Only building
If you need only build image, then use following steps:

1. Run deploy script using command `./deploy_image.sh`
2. Wait until script complete its work

> Note. Make sure all downloaded content is located in working directory.

#### Building settings
You may change default image tag to other by using option `-t`. E.g. for setting image tag to *My_Tag* use command `deploy_image.sh -t My_Tag`
You may deploy only scheme, excepting data with option `-s`. E.g. for deploy without data use command `deploy_image.sh -s`

> Note. By default image tag is *otus_wrex_test_db*.

#### Build and Run
If you need to run container after building image, then use following steps:

1. Run deploy script using command `./deploy_image.sh -R`
2. Wait until script complete its work

#### Running settings
You may change default container name to other by using option `-n`. E.g. for setting container name to *My_Name* use command `deploy_image.sh -R -n My_Name`
You may deploy only scheme, excepting data with option `-s`. E.g. for deploy without data use command `deploy_image.sh -s`

> Note. By default container name is *otus_wrex_test_db*.

You may change default container external port to other by using option `-p`. E.g. Setting port to 5444:
```shell
deploy_image.sh -R -p 5444
```

Also additional docker settings can be passed into script by using option `-d` and space separated string which contains options. E.g. Setting hostname to *my-container*:
```shell
deploy_image.sh -R -d "-h my-container"
```

> Note. Some options are already in use: `-d -p $port:5432 --name $name $tag` they can not be changed.

### Connection to DB
#### Network settings
For connection use network settings defined for container. Internal DB port is 5432, external is defined with option `-p`. E.g. if container was started locally with external port as 5432, then connection address might looks like *localhost:5432*.

#### Credentials
For connection to DB use DB name *postgres*, username *postgres* and password *postgres*

#### DB details
DB study case schema is located in *wrex* schema.
