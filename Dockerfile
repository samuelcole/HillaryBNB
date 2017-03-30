FROM ruby:2.2.6

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        postgresql-client \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app
COPY Gemfile* ./
RUN bundle install

EXPOSE 8080

CMD ["rails", "server", "-b", "0.0.0.0"]
