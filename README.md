# Biobakery Containers

Docker and apptainer build files.
Heavily inspired by https://github.com/tvatanen/microbiome_pipelines

## Building containers

The primary container defined at the base level uses the versions
defined in `environment.yaml` and installs

- kneaddata
- metaphlan
- humann

There are also sub-containers for each individual tool,
but they all use the same procedure.

### Docker

Docker containers are managed by the docker daemon,
rather than having absolute paths.
Assuming the docker daemon is running,

1. Navigate to this repo
2. Build container
3. (optional) Upload to registry

For example,

```
$ docker buildx -t my-biobakery-build:v0.1 .
$ docker tag my-biobakery-build:v0.1 kescobo/my-biobakery-build:v0.1
$ docker push my-biobakery-build:v0.1

```

Here, `my-biobakery-build:v0.1` has 2 parts, the container name (eg `my-biobakery-build`)
and the tag (`v0.1`).
If you want to build with additional tags, you can, and they will be almost instantaneous.

On Dockerhub, the tags have 2 parts themselves, eg `v4-v0.1`,
where the first part `v4` is the biobakery tool versions for humann/metaphlan
and the second part `v0.1` is the container version for this repo.
At some point I should probably have different branches for managing
the biobakery versions, but that's a problem for another day.

To test locally, use eg

```
$ docker run -it --rm my-humann-build humann --help
```

### Apptainer (formerly Singularity)

Apptainer containers are contained in `.sif` files,
which can be nice, because they're portable.
Eg, you can build the container locally, and then put it on other systems.

1. navigate to the root of this repository
2. build


```sh
$ sudo singularity build $CONTAINER_PATH/kneaddata.sif $REPO_PATH/apptainer_files/kneaddata.def
```

where `CONTAINER_PATH` is where you want the container to live,
and `REPO_PATH` is the path to this repository.

## Running containers

To run a biobakery program, use `docker run` or `singularity exec`. For example, to run `humann`,

```sh
$ docker run -it --rm my-biobakery-build humann --version
```

or

```sh
$ singularity exec $CONTAINER_PATH/humann.sif humann $ARGS...
```

But this is pretty annoying, so you can also create and shell script
and alias or symlink it to something in your `$PATH`, for example`/usr/local/bin/humann`:

```sh
#!/bin/sh

singularity exec /murray/containers/humann.sif humann "$@"
```

then `alias humann=/usr/local/bin/humann` or
`ln -s /usr/local/bin/humann ~/.local/human`


Mounting additional files systems

By default, singularity only mounts your working directory and its parents.
If you need to mount other file systems, use `--bind`. 

Eg. if you're running the container from your home folder,
but need to include `/some_filesystem`, run

```sh
$ singularity exec --bind /some_filesystem:/some_filesystem $CONTAINER_PATH/humann.sif humann $ARGS...
```

### Running `metaphlan`

Note - if you try to run metaphlan without specifying a location for the bowtie2 database,
it will try to download it and fail.
To avoid this, download the database to some location,
and then always run metaphlan with `--bowtie2db` specified.

For example,

```sh
$ singularity exec $CONTAINER_PATH/metaphlan.sif metaphlan --install --bowtie2db $BOWTIE2_DB
```

where `$BOWTIE2_DB` is the location that you want the database to live.
Once this is done, run `metaphlan` with

```sh
$ singularity exec $CONTAINER_PATH/metaphlan.sif metaphlan sample1.fastq.gz sample1_profile.tsv --bowtie2db $BOWTIE2_DB
```

To simplify this, you can create a shell script, for example on `hopper`:

```sh
#!/bin/sh

singularity exec --bind $PWD:$PWD --bind /murray:/murray /murray/containers/metaphlan.sif metaphlan "$@" --bowtie2db /murray/databases/metaphlan
```
