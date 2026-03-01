ARG RUBY_VERSION=3.4.7
FROM ruby:${RUBY_VERSION}-slim AS base

WORKDIR /app

ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT=development:test

FROM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential git libpq-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache

COPY . .

ENV SECRET_KEY_BASE_DUMMY=1
RUN bin/rails fly:build

FROM base

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      curl postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /app /app

ENV RAILS_SERVE_STATIC_FILES=true \
    RAILS_LOG_TO_STDOUT=true \
    PORT=8080

EXPOSE 8080

CMD ["bin/rails", "fly:server"]
