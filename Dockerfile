FROM ruby:3.0.6

SHELL ["/bin/bash", "--login", "-c"]

# Set debconf to run non-interactively
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Install essential Linux packages
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    postgresql-client \
    apt-transport-https \
    ca-certificates \
    curl \
    git \
    libssl-dev \
    wget

ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 22.12.0
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/v$NODE_VERSION/bin:$PATH

RUN mkdir $NVM_DIR

RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.40.1/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default \
    && npm install -g yarn

WORKDIR /app

# Copy Gemfile and Gemfile.lock
COPY Gemfile* /app/

RUN gem install bundler

ARG BUNDLE_WITHOUT
ENV BUNDLE_WITHOUT ${BUNDLE_WITHOUT}
RUN bundle install


COPY package.json yarn.lock /app/
RUN . $NVM_DIR/nvm.sh && nvm use default && yarn install

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
