# Rakefile for flexmock        -*- ruby -*-

#---
# Copyright 2003, 2004, 2005, 2006, 2007 by Jim Weirich (jim@weirichhouse.org).
# All rights reserved.

# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#+++
task :noop
require 'rubygems'
require 'rake/clean'
require 'rake/testtask'
require 'rake/contrib/rubyforgepublisher'

require 'rubygems/package_task'

CLEAN.include('*.tmp')
CLOBBER.include("html", 'pkg')

load './lib/flexmock/version.rb'

PKG_VERSION = FlexMock::VERSION

EXAMPLE_RB = FileList['doc/examples/*.rb']
EXAMPLE_DOC = EXAMPLE_RB.ext('rdoc')

CLOBBER.include(EXAMPLE_DOC)
CLEAN.include('pkg/flexmock-*').exclude("pkg/*.gem")

PKG_FILES = FileList[
  '[A-Z]*',
  'lib/**/*.rb',
  'test/**/*.rb',
  '*.blurb',
  'install.rb'
]

RDOC_FILES = FileList[
  'doc/index.rdoc',
  'CHANGES',
  'lib/**/*.rb',
  'doc/**/*.rdoc',
] + EXAMPLE_DOC

task :default => [:test_all, :rspec, :testunit]
task :test_all => [:test]
task :test_units => [:test]
task :ta => [:test_all]

# Test Targets -------------------------------------------------------

Rake::TestTask.new do |t|
  t.test_files = FileList['test/*_test.rb']
  t.libs << "."
  t.verbose = false
  t.warning = true
end

module Configuration
  def self.minitest?
    require 'minitest/autorun'
    return true
  rescue Exception
    return false
  end
end

task :testunit do
  files = FileList['test/test_unit_integration/*_test.rb']
  if ! Configuration.minitest?
    files = files.reject { |fn| fn =~ /minitest/ }
  end
  files.each do |file|
    sh "ruby -Ilib:. #{file}"
  end
end

task :rspec do
  sh "rspec test/rspec_integration"
end

# RCov Target --------------------------------------------------------

begin
  require 'rcov/rcovtask'

  Rcov::RcovTask.new do |t|
    t.libs << "test"
    t.rcov_opts = ['-xRakefile', '-xrakefile', '-xpublish.rf', '-x/Lib*', '--text-report', '--sort', 'coverage']
    t.test_files = FileList['test/test*.rb']
    t.verbose = true
  end
rescue LoadError => ex
end

# RDoc Target --------------------------------------------------------

task :rdoc => ["html/index.html", :fixcss]

file "html/index.html" => ["Rakefile"] + RDOC_FILES do
  Bundler.with_clean_env do
    sh "rdoc -o html --title FlexMock --line-numbers -m doc/index.rdoc #{RDOC_FILES}"
  end
end

EXAMPLE_RB.zip(EXAMPLE_DOC).each do |source, target|
  file target => source do
    open(source, "r") do |ins|
      open(target, "w") do |outs|
        outs.puts "= FlexMock Examples"
        ins.each do |line|
          outs.puts "    #{line}"
        end
      end
    end
  end
end

file "README.md" => ["Rakefile", "lib/flexmock/version.rb"] do
  ruby %{-i.bak -pe '$_.sub!(/^Version: *((\\d+|beta|rc)\\.)+\\d+ *$/i, "Version :: #{PKG_VERSION}")' README.md} # "
end

desc "Fix the Darkfish CSS so that paragraphs in lists have a bit of spacing"
task :fixcss do
  open("html/rdoc.css") do |ins|
    open("html/rdoc.new", "w") do |outs|
      count = 0
      ins.each do |line|
        if line =~ /^ *margin: +0;$/
          count += 1
          if count == 3
            line = "  margin: 0.5em 0;"
          end
        end
        outs.puts line
      end
    end
  end
  rm_f "html/rdoc.css"
  mv "html/rdoc.new", "html/rdoc.css"
end

# Package Task -------------------------------------------------------

if ! defined?(Gem)
  puts "Package Target requires RubyGEMs"
else
  spec = Gem::Specification.new do |s|

    #### Basic information.

    s.name = 'flexmock'
    s.version = PKG_VERSION
    s.summary = "Simple and Flexible Mock Objects for Testing"
    s.description = %{
      FlexMock is a extremely simple mock object class compatible
      with the Test::Unit framework.  Although the FlexMock's
      interface is simple, it is very flexible.
    }				# '

    #### Dependencies and requirements.

    #s.add_dependency('log4r', '> 1.0.4')
    #s.requirements << ""

    #### Which files are to be included in this gem?  Everything!  (Except CVS directories.)

    s.files = PKG_FILES.to_a

    #### C code extensions.

    #s.extensions << "ext/rmagic/extconf.rb"

    #### Load-time details: library and application (you will need one or both).

    s.require_path = 'lib'                         # Use these for libraries.

    #### Documentation and testing.

    s.has_rdoc = true
    s.extra_rdoc_files = RDOC_FILES.reject { |fn| fn =~ /\.rb$/ }.to_a
    s.rdoc_options <<
      '--title' <<  'FlexMock' <<
      '--main' << 'README.rdoc' <<
      '--line-numbers'

    #### Author and project details.

    s.author = "Jim Weirich"
    s.email = "jim.weirich@gmail.com"
    s.homepage = "https://github.com/jimweirich/flexmock"
  end

  Gem::PackageTask.new(spec) do |pkg|
    pkg.need_zip = true
    pkg.need_tar = false
  end
end

require 'rake/contrib/publisher'
require 'rake/contrib/sshpublisher'

publisher = Rake::CompositePublisher.new
publisher.add(Rake::RubyForgePublisher.new('flexmock', 'jimweirich'))

desc "Publish the documentation on public websites"
task :publish => [:rdoc] do
  publisher.upload
end

task :specs do
  specs = FileList['test/spec_*.rb']
  ENV['RUBYLIB'] = "lib:test:#{ENV['RUBYLIB']}"
  sh %{rspec #{specs}}
end

task :tag do
  sh "git tag 'flexmock-#{PKG_VERSION}'"
end
