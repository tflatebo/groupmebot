# Rakefile

task :default => :test

desc "Run all tests"
task(:test) do
  puts 'Running tests...'
  Dir['./spec/**/*_spec.rb'].each { |f| 
    puts 'loading ' + f.to_s
    load f 
  }
end
