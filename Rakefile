desc "Build and publish gem"
task :release do
  puts "Building and releasing BigQuery"
  sh "rm -f *.gem"
  sh "gem build bigquery.gemspec && gem push #{release}"
end

desc "Build the gem"
task :build do
  puts "Building BigQuery"
  sh "rm -f *.gem"
  sh "gem build bigquery.gemspec"
end

def release
  "bigquery-#{File.read("bigquery.gemspec")[/s.version *= *"(.*?)"/, 1]}"
end