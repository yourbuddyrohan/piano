Piano
=====

Out-of-the-box Sinatra server for fast website sketching using Haml (or Slim) and Sass and CoffeeScript (and YAML!).

The magic triplet, one command away!

Installation
------------

    gem install piano

Standalone Usage
----------------

    $ piano [<port-number> <environment> [options]]

Piano will start a Sinatra server based in the same folder where you run the command, in the port and environment given. If no port or environment is given, Piano will start in the default Sinatra port `4567` and the default environment `development`. 

[Haml](http://haml-lang.com) `.haml` (or [Slim](http://slim-lang.com) `.slim`) files and [Sass](http://sass-lang.com) `.sass` and [CoffeeScript](http://github.com/josh/ruby-coffee-script) `.coffee` files in the base folder will automatically be mapped to urls.

    yoursite.com/users          => /users.haml or /users.slim
    yoursite.com/style.css      => /style.sass
    yoursite.com/app.js         => /app.coffee
    yoursite.com/folder/file    => /folder/file.haml or /folder/file.slim

Other files (images, plain text files, etc) will be loaded from the `server/folder/public` as is default behavior in Sinatra.

Adding routes and stuff
-----------------------

Piano will try to load a file named `Pianofile`. There you can add functionality, like custom helpers and routes.

Any route added to the `Pianofile` will be parsed before the default routes from Piano, overriding them. 

#### Sample `Pianofile`

This file, for example, will bring back the email masking functionality that was deprecated in version 0.7.6

  get '/' do
    'Hi! Just testing'
  end

  get '/email' do
    "Here is my email: #{unicode_entities('xavier@example.com')}"
  end

  post '/' do  # The '/' route, is considered "index" for the haml and yaml files
    require "psych"

    File.open 'data/index.yaml', 'w' do |file|
      file.write params.to_yaml
    end
  end

  helpers do
    def unicode_entities(string)
      encodings = ''
      string.codepoints do |c|
        encodings += "&##{c};"
      end
      encodings
    end
  end

== YAML Data

When receiving a request for <tt>"/users"</tt>, Piano will look up for a YAML file <tt>server/folder/data/users.haml</tt>. If it is there, the YAML file will be loaded and available for the correspondent Haml template in the <tt>@data</tt> variable.

== 5 minutes site!

...all working with stylesheet, scripts and YAML data sources.

==== folder/index.haml

  !!! 5
  %head
    %title= @data['title']
    = style 'style.css'
    = script 'app.js'
  %body
    %h1= @data['title']
    %p= @data['description']
    %ul
      - @data['list'].each do |item|
        %li= item

Or if slim:

==== folder/index.slim

  doctype html
  head
    title= @data['title']
    == style 'style.css'
    == script 'app.js'
  body
    h1= @data['title']
    p= @data['description']
    ul
      - @data['list'].each do |item|
        li= item

==== folder/style.sass

  body
    width: 960px
    margin: 0 auto
    font:
      family: sans-serif
      size: 15px

==== folder/app.coffee

  alert "This is too simple to be true"

==== folder/data/index.yaml

  title: 5 minutes site!
  description: Is amazing how simple it gets
  list:
    - and I can have
    - a list
    - also.

Note: You can find this sample in the repository within the <tt>/sample</tt> folder.

== Going :production!

Piano goes production in command line just adding <tt>production</tt> to its arguments. When it goes, it goes this way:

* Now any unmatched route will give a zero-information-disclosure nice old 404 error page
* And the default behaviour for 500 errors in Sinatra.

For nicety sake, you can personalize 404 pages simply by creating a <tt>server/folder/404.haml</tt> template. Beware when you do: out there be dragons.

Note: you can also add a <tt>server/folder/data/404.yaml</tt> file to keep layer separation even in your error pages.

== Command line options summary

* Port number: Any number passed as an argument to the <tt>piano</tt> command will be used as the port number.
* Environment: Any string that does not matches any other argument will be setted as the environment. 
* <tt>noetags</tt>: Adding <tt>noetags</tt> to the shell command will cause Piano to run without etags.
* <tt>views:<views_path></tt> Sets the views folder, within server/folder
* <tt>public:<public_path></tt> Sets the public folder, within server/folder
== Library Usage as Sinatra Extension

Piano is fully usable as a Sinatra Extension. Provide the helpers, <tt>sass("template")</tt>, <tt>coffee("template")</tt>, <tt>try_haml("template")</tt>.

Note: Prior to version 0.8.2, Piano was intended to be used as a subclass of Sinatra::Base, but now it works both as a Sinatra Extension and as a subclass.
Further moves to keep most functionality as a Sinatra Extension will be done in the future, except in the <tt>piano/routes</tt>.

  require 'piano'

  class MyPiano < Sinatra::Base
    helpers Sinatra::Piano

    get '/' do
      "Let's change the default behaviour"
    end
  end

  MyPiano.run!

=== Routes

To load the routes (the ones that match your requests with your haml, sass and coffee templates) you have to require also <tt>"piano/routes"</tt>. Usually you'll want to load them after you define your own ones, otherwise you won't be able to override them.

  require 'piano/base'

  class Piano::Base
    get '/special' do
      "A special route, overriding the default 'special.haml'"
    end
  end

  require 'piano/routes'

  Piano::Base.play! # .play! added 4 the lulz; Piano.run! will do the trick aswell

<tt>Piano</tt> inherits <tt>Sinatra::Base</tt>, so all of <tt>Sinatra::Base</tt> own methods are available. Read the Sinatra documentation (http://www.sinatrarb.com/intro) for further information. 

Tip: put

  Piano::Base.environment = :production

just before letting it play for play in production environment!

By setting <tt>Piano::Base.etags = :off</tt>, etags will be disabled.

== Candies for the kidz

=== Convenience helpers

==== <tt>style</tt> and <tt>script</tt>

Piano features two convenience helpers to include stylesheets and javascripts: <tt>style("style.css")</tt> and <tt>script("app.js")</tt>.

You can use them in your haml templates like this:

  !!! 5
  %html
    %head
      %title Out-of-the-box is pretty awesome!
      = style 'style.css'
      = script 'app.js'

Or in slim:

  doctype html
  html
    head
      title Out-of-the-box is pretty awesome!
      == style 'style.css'
      == script 'app.js'

==== <tt>extract</tt>

Another helper you may find useful is <tt>extract("source_text/html", word_count = 80)</tt>. Returns an extract of the first <tt>word_count</tt> words (default is 80), html tags stripped, and closed by <tt>"..."</tt> . It does nothing is the text is less than <tt>word_count</tt> words in length.

  %p= extract content, 25

=== <tt>link</tt>

No, it does not print an anchor: it strips all strange characters from a string and replaces all whitespace with "-". If the text is too long, it cuts it. 

Really useful when generating uri's for articles, or html id attributes.

  %a(href="/articles/#{article.id}-#{link(article.title)}")= article.title

or

  %h2(id="#{link(subtitle,4)}")= subtitle

In this example, the second argument (4) ensures that the link is done with no more than four of the subtitle's words.

=== <tt>flash</tt>

Piano now comes bundled with https://github.com/SFEley/sinatra-flash so you can use the <tt>flash</tt> helper as in Rails. (0.10.9+) 

Please go to the https://github.com/SFEley/sinatra-flash documentation for further reading. Is a nice gem and you might find it really useful.

Code is poetry.

=== Etags

Since parsing YAML, Sass, Haml and CoffeeScript can be quite a burden for the processor, each response is marked with an Etag hash featuring the required file name and the timestamp of the last modification.

Etags cause client side caching. This should not be a problem since the hash changes every time a source file is modified (including the YAML data files), forcing the User-Agent to update its cache, but still is worth noting as I might not be fully aware of cache-related issues that Etag-ging may trigger.

== Desired (future) features

* Features and specs covering all Piano's functionality.
* Agnosticism. Currently Piano is kind of HAML&SASS monotheistic.
* <tt>style</tt> and <tt>script</tt> helpers working with symbols.
* More helpers for semantic data handling.
* Deploy of sample with command line <tt>--sample</tt> argument.
* Online source files edition.

* Now it would be nice to give Piano personalized templates not only to 404 but for all error pages, specially 500
* Custom error when there's no data

== Known issues

* Sinatra::Piano rules break when a route consisting of only a number is passed

== Tips

As for v0.7.3, Piano has now the ability to go <tt>:production</tt> mode both in command line and library modes.

== Deprecated functions

From version 0.11.0 on, <tt>flash?</tt> has been deprecated and the <tt>flash</tt> helpers has been replaced with the <tt>sinatra-flash</tt> gem.

From version 0.7.6 on, <tt>unicode_entities</tt> has been deprecated for better Ruby version backwards compatibility.

= Collaborators

- Alexey Gaziev (http://github.com/gazay)
- Sasha Koss (http://github.com/kossnocorp)

= License

(The MIT License)

Copyright © 2011:

* Xavier Via (http://xaviervia.com.ar)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ‘Software’), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.