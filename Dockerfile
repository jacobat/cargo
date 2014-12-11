FROM jacobat/ruby:2.1.5-3

RUN apt-get update
RUN apt-get install -y build-essential
RUN apt-get install -y nodejs

WORKDIR /app

ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN bundle install

ADD . /app

EXPOSE 3000
CMD rails s -P /var/run/server.pid
