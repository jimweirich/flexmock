
task :preview do
  sh "ghpreview #{FileList['README.{md,markdown}']}"
end
