FROM ruby:2.6.6

# Install essential Linux packages
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    postgresql-client \
    nodejs

WORKDIR /app

# Copy Gemfile and Gemfile.lock
COPY Gemfile* /app/

RUN gem install bundler

ARG BUNDLE_WITHOUT
ENV BUNDLE_WITHOUT ${BUNDLE_WITHOUT}
RUN bundle install

# Copy the Rails application into place
COPY . /app

# Add a script to be executed every time the container starts.
# TODO: use the entryscript to WAIT for the other containers, so the app survives restart?
# Right now we have to start containers in correct order and wait for services to be ready
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD [ "bin/rails", "server", "-p", "3000", "-b", "0.0.0.0" ]
