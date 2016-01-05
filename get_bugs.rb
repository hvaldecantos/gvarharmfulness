require 'json'
require 'csv'
require 'set'
#mongoexport --db curl-6_5_curl-7_42_0 --collection globals | ruby db_to_csv.rb

contents = STDIN.read
json = JSON.parse(contents)

gv_related_bugs = 0
gv_bugs_count = 0
set = Set.new
names=Set.new
total = 0
removed = 0

json.each do |k,v|

  if not v["name"]
   next
  end
 
  total += 1

  gv_bugs_count += v["bug_count"].to_i

  if v["bug_count"].to_i > 0
    gv_related_bugs += 1
    v["bug_shas"].each do |bug_sha|
      set.add(bug_sha['sha'])
      names.add(v["name"])
      if(bug_sha['removed'])
        removed +=1
        puts "-------------> #{bug_sha['sha']} #{v['name']}"
      end
    end
  end
   
  
end

puts "total gv: " + total.to_s
puts "gv related to bugs: " + gv_related_bugs.to_s
puts "gv bugs count: " + gv_bugs_count.to_s
puts "bug fix rel to gvar: " + set.size.to_s
puts "gv removed: #{removed}"
wd = Dir.getwd
