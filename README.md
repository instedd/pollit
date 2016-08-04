Pollit
======

[![Build Status](https://travis-ci.org/instedd/pollit.svg)](https://travis-ci.org/instedd/pollit)

[Pollit](pollit.instedd.org) helps you use the ease of text messaging to conduct surveys reaching your audience at their convenience. It will guide each participant step by step through your survey, collecting the results in real time. Using text messaging allows you to scale the number of people you reach and lets them answer anytime, anywhere.

Installation
============

Simply clone the repository and fill the following settings file before starting the server with rails server command:

    config/settings.yml
    config/nuntium.yml
    config/database.yml
    config/guisso.yml
    config/hub.yml

Configuring Nuntium
-------------------

Nuntium settings are located in `config/nuntium.yml`.

The Nuntium Application associated to a Pollit instance must be configured in this way:
  * Application name: the value of `application` in `config/nuntium.yml`
  * Interface configuration:
    * HTTP Post callback: `/nuntium/receive_at`
    * User: the value of `at_post_user` in `config/nuntium.yml`
    * Password: the value of `at_post_password` in `config/nuntium.yml`
  * Delivery acknowledgement:
    * HTTP Post: `/nuntium/delivery_callback`
    * User: the value of `at_post_user` in `config/nuntium.yml`
    * Password: the value of `at_post_password` in `config/nuntium.yml`

Development
===========

Docker development
------------------

`docker-compose.yml` file build a development environment mounting the current folder and running rails in development environment.

Run the following commands to have a stable development environment.

```
$ docker-compose run --rm --no-deps web bundle install
$ docker-compose up -d db
$ docker-compose run --rm web rake db:setup
$ docker-compose up
```

To setup and run test, once the web container is running:

```
$ docker-compose exec web bash
root@web_1 $ rake
```

API
===

Pollit provides a simple RESTful read-only API for querying Answers, Polls, Questions and Respondents.

Authentication
--------------

Authentication is handled via [GUISSO](https://github.com/instedd/guisso), allowing access via [both OAuth and basic auth](https://github.com/instedd/alto_guisso_rails#allow-oauth-and-basic-authentication-with-guisso-credentials). If the user is currently logged in to the application, all requests to the API from the browser will also work, facilitating the exploration of the API.

Formats
-------

All endpoints support both JSON and XML format. The extension used in the URL will determine which format is returned by the API.

Endpoints
---------

* List all user Polls
```
http://pollit.instedd.org/api/polls.json
```

* Get a poll given its numeric ID
```
http://pollit.instedd.org/api/polls/ID.json
```

* List all respondents from a Poll
```
http://pollit.instedd.org/api/polls/POLL_ID/respondents.json
```

* Get a respondent given its numeric ID
```
http://pollit.instedd.org/api/polls/POLL_ID/respondents/ID.json
```

* List all questions from a Poll
```
http://pollit.instedd.org/api/polls/POLL_ID/questions.json
```

* Get a question given its numeric ID
```
http://pollit.instedd.org/api/polls/POLL_ID/questions/ID.json
```

* List all answers from a Poll
```
http://pollit.instedd.org/api/polls/POLL_ID/answers.json
```

* Get an answer given its numeric ID
```
http://pollit.instedd.org/api/polls/POLL_ID/answers/ID.json
```

Entities
--------

**Poll**

```json
{
  "confirmation_word": "Yes",
  "created_at": "2011-11-04T19:11:53Z",
  "current_occurrence": null,
  "description": "A test poll",
  "form_url": "URL_TO_FORM",
  "goodbye_message": "Thank you for your answers!",
  "id": 1,
  "owner_id": 1,
  "post_url": "URL_FOR_ANSWERS",
  "recurrence": {
    "start_time": "2015-01-01T12:00:00+00:00",
    "rrules": [],
    "rtimes": [],
    "extimes": []
  },
  "status": "started",
  "title": "Test poll",
  "updated_at": "2015-01-01T12:00:00+00:00",
  "welcome_message": "Answer 'yes' if you want to participate in this poll."
}
```

**Respondent**

```json
{
  "confirmed": true,
  "created_at": "2015-01-01T20:00:00Z",
  "current_question_id": null,
  "current_question_sent": true,
  "id": 1,
  "phone": "PHONE_NUMBER",
  "poll_id": 1,
  "pushed_at": "2015-01-01T20:00:00Z",
  "pushed_status": "succeeded",
  "updated_at": "2015-01-01T20:00:00Z"
}
```

**Question**

```json
{
  "collects_respondent": false,
  "created_at": "2015-01-01T20:00:00Z",
  "description": "Enter your name",
  "field_name": "FIELD_NAME",
  "id": 1,
  "kind": "text",
  "numeric_max": null,
  "numeric_min": null,
  "options": [],
  "poll_id": 1,
  "position": 1,
  "title": "What is your name?",
  "updated_at": "2015-01-01T20:00:00Z"
}
```

**Answer**

```json
{
  "id": 1,
  "question_id": 1,
  "question_title": "What is your name?",
  "respondent_phone": "PHONE_NUMBER",
  "occurrence": null,
  "timestamp": "2015-01-01T20:00:00Z",
  "response": "John Doe"
}
```
