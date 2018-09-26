require 'rubygems'
require 'bundler/setup'
require 'httparty'
require 'json'
require 'optparse'

days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
days_map = {}
average_commit = {}
max = 0

#default values in case flags aren't passed
options = {}
options[:repo] = "kubernetes/kubernetes"
options[:weeks] = 0
options[:show_max] = false
options[:ascending] = true
options[:descending] = false

#parse flags passed in command line
def options(options)
  OptionParser.new do |opts|
    opts.on('-r', '--repo owner/repo format', 'adds repo to path') do |repo|
      options[:repo] = repo
    end
    opts.on("-w", "--weeks n", "Number of weeks. Default: 52") do |weeks|
      options[:weeks] = weeks
    end
    opts.on("-max", "--max day", "Returns busiest day") do |max|
      options[:show_max] = true
    end
    opts.on("-asc", "--asc true", "Sorts by least to busiest") do |max|
      options[:acending] = true
      options[:descending] = false
    end
    opts.on("-desc", "--desc day", "Sorts by busiest to least busy") do |max|
      options[:descending] = true
      options[:ascending] = false
    end
    opts.on('-h', '--help', 'Display this screen') do
      puts opts
      exit
    end
  end.parse!
end

options(options)

def fetch_repo(options)
  response = HTTParty.get("https://api.github.com/repos/#{options[:repo]}/stats/commit_activity")
  results = JSON.parse(response.body)
  new_results_array = results.reverse
end

new_results_array = fetch_repo(options)

start = 52 - options[:weeks].to_i
weeks_back = 52 - start

def fetch_weeks_commits(new_results_array, weeks_back)
  weeks_back.times do
    new_results_array.pop
  end
  new_results_array
end

fetch_weeks_commits(new_results_array, weeks_back)

#build hash to keep track of total commits over the year for each day of the week
def build_map(average_commit, days, days_map, stat)
  stat['days'].each_with_index do |day, index|
    if days_map[days[index]] === nil
      days_map[days[index]] = 0
    else
      days_map[days[index]] += day
    end
    if average_commit[days[index]] === nil
      average_commit[days[index]] = 0
    else
      array = []
      array.push(stat['days'][index])
      total = array.reduce(:+)
      average = total / array.size
      average_commit[days[index]] = average
    end
  end
end

new_results_array.each do |stat|
  build_map(average_commit, days, days_map, stat)
end

#sort results based on the flags user pass in
def sort_result(average_commit, options)
  if options[:ascending]
    average_commit = Hash[average_commit.sort_by {|k, v| v}]
  end

  if options[:descending]
    average_commit = Hash[average_commit.sort_by {|k, v| -v}]
  end
  average_commit
end

average_commit = sort_result(average_commit, options)

def print_result(average_commit, days, days_map, options)
  if options[:show_max]
    new_value = days_map.values.max
    idx = days_map.key(new_value)
    new_index = days.index(idx)
    puts "Day: #{idx} Average: #{average_commit[idx]}, Total: #{days_map[idx]}"
  else
    average_commit.keys.each do |day|
      puts "#{day}, average: #{average_commit[day]}, total: #{days_map[day]}"
    end
  end
end

print_result(average_commit, days, days_map, options)
