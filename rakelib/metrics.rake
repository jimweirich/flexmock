METRICS_FILES = FileList['lib/**/*.rb']

task :flog, [:all] do |t, args|
  flags = args.all ? "--all" : ""
  flags = "-m #{flags}"
  Bundler.with_clean_env do
    sh "flog #{flags} #{METRICS_FILES}" do |status|
      if status.nil?
        puts "Install flog with: 'gem install flog'"
      end
    end
  end
end

task :flay do
  Bundler.with_clean_env do
    sh "flay #{METRICS_FILES}" do |status|
      if status.nil?
        puts "Install flay with: 'gem install flay'"
      end
    end
  end
end
