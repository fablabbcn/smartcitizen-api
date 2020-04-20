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

# Speed up nokogiri install
ENV NOKOGIRI_USE_SYSTEM_LIBRARIES 1
ENV BUNDLER_VERSION 2.0.2
RUN gem install bundler

RUN bundle install

# Copy the Rails application into place
COPY . /app

CMD [ "bin/rails", "server", "-p", "3000", "-b", "0.0.0.0" ]
#CMD [ "bundle", "exec", "puma" ]
