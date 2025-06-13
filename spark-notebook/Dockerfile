FROM jupyter/all-spark-notebook:spark-3.3.0

COPY --chown=1000:1000 require ./
COPY --chown=1000:1000 require /root/

USER root

RUN rm -rf /root/requirement.txt

RUN apt-get update

RUN DEBIAN_FRONTEND=noninteractive DEBCONF_NOWARNINGS=yes apt-get install -y \
	libmagic-dev pkg-config fuse libfuse3-3 python-llfuse-doc libfuse-dev

USER 1000

ENV GRANT_SUDO=yes

RUN pip install --quiet --no-cache-dir -r requirement.txt && rm -rf requirement.txt