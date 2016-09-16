# docker build -t yuanying/gitlab-runner .
FROM gitlab/gitlab-runner:latest
MAINTAINER yuan-docker@fraction.jp

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

ENTRYPOINT ["/sbin/entrypoint.sh"]
