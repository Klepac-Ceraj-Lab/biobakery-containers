# The build-stage image:
FROM mambaorg/micromamba:1.4.3

# docker buildx -t biobakery .
# docker run -it --rm biobakery humann --version
# docker run -it --rm biobakery metaphlan --version
# docker run -it --rm biobakery kneaddata --version

# docker buildx -t biobakery:v4-v0.1 .
# docker tag biobakery:4-v0.1 
# docker push 

COPY --chown=$MAMBA_USER:$MAMBA_USER environment.yaml /tmp/env.yaml
RUN micromamba install -y -n base -f /tmp/env.yaml && \
    micromamba clean --all --yes
