FROM ruby:latest

RUN apt-get update -qq && apt-get install -y build-essential

# for postgres
RUN apt-get install -y libpq-dev

# for nokogiri
RUN apt-get install -y libxml2-dev libxslt1-dev

# for capybara-webkit
RUN apt-get install -y libqt4-webkit libqt4-dev xvfb

# for a JS runtime
RUN apt-get install -y nodejs

RUN git clone https://github.com/teohoch/DocArk.git

ENV APP_HOME /DocArk
WORKDIR $APP_HOME

RUN cd /DocArk

RUN bundle install

COPY jenkins/DocArk/docker-entrypoint.sh /usr/local/bin/
COPY jenkins/DocArk/database.yml /database.yml
RUN ln -s usr/local/bin/docker-entrypoint.sh / # backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["rails", "server", "-p", "3000", "-b", "0.0.0.0"]
