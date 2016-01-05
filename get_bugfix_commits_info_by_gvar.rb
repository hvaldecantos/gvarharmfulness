require 'json'
require 'csv'
require 'set'

# Example: Command to run cpio
# mongoexport --db i_cpio --collection globals | ruby get_bugfix_commits_info_by_gvar.rb ../projects/cpio/ > cpio_gv_bugs.txt

contents = STDIN.read
json = JSON.parse(contents)

project_path = ARGV[0]

gvars = {}

json.each do |k,v|
  next if not v["name"]
  gvars[v['name']] = []
  if v["bug_count"].to_i > 0
    v["bug_shas"].each do |bug_sha|
      gvars[v['name']] << bug_sha['sha']
    end
  end
end

wd = Dir.getwd
Dir.chdir(project_path)

gvars.each do |name, shas|
  puts "####################################################################################"
  puts "Globalvar: #{name}"
  puts "Bugs: #{shas.size}"
  puts "####################################################################################"
  shas.each do |sha|
    puts `git log --unified=0 -1 #{sha}`
    puts "------------------------------------------------------------------------------------"
  end
end

Dir.chdir(wd)

