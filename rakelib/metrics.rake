METRICS_FILES = FileList['lib/**/*.rb']

task :metrics => [:cane, :flog, :flay]

task :flog, [:all] do |t, args|
  flags = args.all ? "--all" : ""
  flags = "-m #{flags}"
  Bundler.with_clean_env do
    puts "\nFLOG:"
    sh "flog #{flags} #{METRICS_FILES}" do |status, flag|
      if status.nil?
        puts "Install flog with: 'gem install flog'"
      end
    end
  end
end

task :flay do
  Bundler.with_clean_env do
    puts "\nFLAY:"
    sh "flay #{METRICS_FILES}" do |status, flag|
      if status.nil?
        puts "Install flay with: 'gem install flay'"
      end
    end
  end
end

task :cane, [:max_line] do |t, args|
  max_line = args.max_line || 90
  Bundler.with_clean_env do
    puts "\nCANE:"
    sh "cane --style-measure #{max_line} --no-doc" do |status, flag|
      if status.nil?
        puts "DBG: [status, flag]=#{[status, flag].inspect}"
        puts "Install cane with: 'gem install cane'"
      end
    end
  end
end
