# docker build -t yuanying:deregister .
FROM ruby:2.3.1
RUN gem install bundler
RUN gem install foreman
COPY . /app
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY server.rb /app/server.rb
COPY config.ru /app/config.ru
COPY Procfile /app/Procfile
COPY config.yaml /app/config.yaml

EXPOSE 4567
RUN bundler
ENV CONSUL_URL=http://localhost:8500
ENV CONFIG_FILE=/app/config.yaml
CMD ["foreman", "start", "-d", "/app", "-f", "/app/Procfile", "-p", "4567"]
