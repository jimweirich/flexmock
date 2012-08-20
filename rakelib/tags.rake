#!/usr/bin/env ruby
# -*- ruby -*-

module Tags
  RUBY_FILES = FileList['**/*.rb'].exclude("pkg")
  PROG = ENV['TAGS'] || 'ctags'
end

namespace "tags" do
  desc "Update the Tags file for emacs"
  task :emacs => Tags::RUBY_FILES do
    puts "Making Emacs TAGS file"
    sh "#{Tags::PROG} -e #{Tags::RUBY_FILES}", :verbose => false
  end
end

desc "Update the Tags file for emacs"
task :tags => ["tags:emacs"]
