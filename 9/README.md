# Otus RDBMS study case

This is RDBMS study case. Postgresql DB and study case schema *wrex* was packet into Docker image.

> Note. Current version contains only schema not any data.

## Usage
### Requirements
Check for system has `zcat` and `docker` installed.

### Building
#### Building process
1. Download directory content
2. Go to directory with downloaded content
3. Add execution permission for building script using command `chmod +x build_image.sh`
4. Run building script using command `./build_image.sh`
5. Wait until script complete its work

> Note. Make sure all downloaded content is located in working directory.

#### Building settings
You may change default image tag to other by using option `-n`. E.g. for set image tag to *My_Tag* use command `build_image.sh -n My_Tag`

> Note. By default container tag is *otus_wrex_test_db*.

### Running
#### Run container
For running container use settings related to your system. E.g. for image tagged with default tag and external port 5432 it is following command:
```shell
docker run -d -p 5432:5432 --name otus_wrex_test_db otus_wrex_test_db
```

#### Connection to DB
##### Network settings
For connection use network settings defined for container. Internal DB port is 5432, external is defined during container startup. E.g. if container was started locally with external port as 5432, then connection address might looks like *localhost:5432*.

##### Credentials
For connecting to DB use username *postgres* and password *postgres*
