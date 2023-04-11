FROM ruby:3.2.0

RUN apt update && apt -y install unixodbc unixodbc-dev freetds-dev freetds-bin tdsodbc sqlite3

RUN adduser app
USER app

ENV GEM_HOME="/usr/local/bundle"
ENV PATH $GEM_HOME/bin:$GEM_HOME/gems/bin:$PATH
ENV NOTES_ENV="development"
ENV DATABASE_URL=""
ENV DB_ADAPTER=""
ENV DB_HOST=""
ENV DB_PORT=""
ENV DB_USERNAME=""
ENV DB_PASSWORD=""
ENV DB_DATABASE=""
ENV BIND_HOST="0.0.0.0"
ENV BIND_PORT="80"

COPY --chown=app Gemfile Gemfile.lock ./
RUN bundle install

COPY --chown=app . .

CMD bash start.sh

EXPOSE $BIND_PORT