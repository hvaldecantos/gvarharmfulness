require 'json'
require 'csv'
require 'set'
require 'envyable'

Envyable.load('./config/env.yml', 'database')
PREFIX = ENV['PREFIX_DB_NAME']

# mongoexport --db i_cpio --collection globals | ruby get_gvar_def.rb 

project = ARGV[0]

contents = STDIN.read
json = JSON.parse(contents)

total_gv = 0

headers = ["gv", "filename", "line", "sha", "bugcount"]
csv_filename = "results/#{PREFIX}_#{project}_gvar_def.csv"
CSV.open(csv_filename, "w+") do |row|
  row << headers
end

json.each do |k,v|

  if not v["name"]
   next
  end
 
  total_gv += 1

  CSV.open(csv_filename, "a+") do |row|
    row << [v["name"],v["filename"],v["line_num"],v["first_sha"],v["bug_count"]]
  end
  
end

puts "total gv: " + total_gv.to_s
