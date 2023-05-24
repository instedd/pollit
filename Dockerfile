FROM ruby:2.3

# Cleanup expired Let's Encrypt CA (Sept 30, 2021)
RUN sed -i '/^mozilla\/DST_Root_CA_X3/s/^/!/' /etc/ca-certificates.conf && update-ca-certificates -f

RUN echo 'deb http://archive.debian.org/debian stretch main\n\
  deb http://archive.debian.org/debian-security stretch/updates main' > /etc/apt/sources.list

RUN \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install gem bundle
ADD Gemfile /app/
ADD Gemfile.lock /app/
WORKDIR /app
RUN bundle install --jobs 3 --deployment --without development test

# Install the application
ADD . /app

# Precompile assets
RUN bundle exec rake assets:precompile RAILS_ENV=production SECRET_KEY_BASE=secret

# Add scripts
ADD docker/migrate /app/migrate
ADD docker/database.yml /app/config/database.yml

ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_SERVE_STATIC_ASSETS=true
ENV RAILS_ENV=production
ENV BIND=tcp://0.0.0.0:80
ENV PUMA_TAG=pollit
ENV PUMA_PARAMS=
EXPOSE 80

CMD exec bundle exec puma -e $RAILS_ENV -b $BIND --tag $PUMA_TAG $PUMA_PARAMS
