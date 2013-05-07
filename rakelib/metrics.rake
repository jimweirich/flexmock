METRICS_FILES = FileList['lib/**/*.rb']

task :flog, [:all] do |t, args|
  flags = args.all ? "--all" : ""
  Bundler.with_clean_env do
    sh "flog #{flags} #{METRICS_FILES}"
  end
end

task :flay do
  Bundler.with_clean_env do
    sh "flay #{METRICS_FILES}"
  end
end
