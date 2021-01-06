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

# Skip installing development / test gems, saves 20s build time
ENV BUNDLE_WITHOUT development test
RUN bundle install

# Copy the Rails application into place
COPY . /app

CMD [ "bin/rails", "server", "-p", "3000", "-b", "0.0.0.0" ]
#CMD [ "bundle", "exec", "puma" ]
