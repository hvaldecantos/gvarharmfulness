require 'csv'
require 'envyable'
require 'logger'

def sec_to_dhms s
  dhms = [60, 60, 24].reduce([s]) { |m,o| m.unshift(m.shift.divmod(o)).flatten }
  "%0.2d %0.2d:%0.2d:%0.2d" % dhms
end

def get_project_age filters, cwd = '.'
 `gvar --project-inf --filters="#{filters}" --rev-range=master --logpath=#{cwd}`.strip
end

def get_all_commit_num filters, cwd = '.'
 `gvar --list-shas --filters="#{filters}" --rev-range=master --logpath=#{cwd} | wc -l`.strip
end

def get_all_bf_commits_num filters, cwd = '.'
  `gvar --count-all-bugs --filters="#{filters}" --rev-range=master --logpath=#{cwd}`.strip
end

def get_extra_data project
  gvars = gvars_rel_bf = gvars_bf_count = bfs_rel_gvar = gvars_removed = 0
  `mongoexport --db #{PREFIX}_#{project} --collection globals | ruby get_bugs.rb`.each_line do |line|
    gvars_match = line.match /total gv:\s*(\d+)/
    unless gvars_match.nil?
      gvars = gvars_match.captures[0].to_i
    end

    gvars_rel_bf_match = line.match /gv related to bugs:\s*(\d+)/
    unless gvars_rel_bf_match.nil?                    
      gvars_rel_bf = gvars_rel_bf_match.captures[0].to_i
    end

    gvars_bf_count_match = line.match /gv bugs count:\s*(\d+)/
    unless gvars_bf_count_match.nil?
      gvars_bf_count = gvars_bf_count_match.captures[0].to_i
    end 

    bfs_rel_gvar_match = line.match /bug fix rel to gvar:\s*(\d+)/
    unless bfs_rel_gvar_match.nil?
      bfs_rel_gvar = bfs_rel_gvar_match.captures[0].to_i
    end 

    gvars_removed_match = line.match /gv removed:\s*(\d+)/
    unless gvars_removed_match.nil?
      gvars_removed = gvars_removed_match.captures[0].to_i
    end
  end
  [gvars, gvars_rel_bf, gvars_bf_count, bfs_rel_gvar, gvars_removed]
end

#############################################
Envyable.load('./config/env.yml', 'database')

PREFIX = ENV['PREFIX_DB_NAME']
cwd = Dir.getwd

headers = ["project", "branch", "dir", "age", "commits", "bfs", "gvars", "bfs_rel_gvar", "gvars_rel_bf", "gvars_bf_count", "gvars_removed"]
CSV.open("results/#{PREFIX}_data_gvar.csv", "w+") {|row| row << headers }

start_time_whole = Time.now

File.open('config/projects_to_analyze.config').each_line do |line|
  project, dir = line.split

  start_time = Time.now
  puts "------------------> #{project}"
  wd = cwd + "/projects/" + project

  Logger.new("#{cwd}/command_execution.log").info("-------------------------------------------------------")
  Logger.new("#{cwd}/command_execution.log").info("#{wd} in dirs #{dir}")

  begin
    Dir.chdir wd
    # `git checkout master`
    `gvar --checkout --sha=master --logpath=#{cwd}`
    `gvar --store-commits --db=#{PREFIX}_#{project} --directories="#{dir}" --rev-range=master --logpath=#{cwd}`
    # `git checkout master`
    `gvar --checkout --sha=master --logpath=#{cwd}`
    filters = `gvar --find-git-filters --directories="#{dir}" --logpath=#{cwd}`.strip
    age = get_project_age(filters, cwd)
    commits = get_all_commit_num(filters, cwd)
    bf_commits = get_all_bf_commits_num(filters, cwd)
    # `git checkout master`
    `gvar --checkout --sha=master --logpath=#{cwd}`
    Dir.chdir cwd
  end
  # code to time
  gvar_end_time = Time.now
  puts "data extrated from project and saved in mongo database #{PREFIX}_#{project} [#{sec_to_dhms(gvar_end_time - start_time)}]"

  gvars, gvars_rel_bf, gvars_bf_count, bfs_rel_gvar, gvars_removed = get_extra_data(project)

  CSV.open("results/#{PREFIX}_data_gvar.csv", "a+") do |row|
    row << [project, "master", dir, age, commits, bf_commits, gvars, bfs_rel_gvar, gvars_rel_bf, gvars_bf_count, gvars_removed]
  end
  csv_end_time = Time.now
  puts "data analized from db and saved in #{PREFIX}_data_gvar.csv file [#{sec_to_dhms(csv_end_time - gvar_end_time)}]"

  # Create a csv file with the definition of all gvars in the project
  puts `mongoexport --db #{PREFIX}_#{project} --collection globals | ruby get_gvar_def.rb #{project}`

  # Write in a file all bugfix commits messages and patches ordered by gvars
  `mongoexport --db #{PREFIX}_#{project} --collection globals | ruby get_bugfix_commits_info_by_gvar.rb projects/#{project}/ > results/#{PREFIX}_#{project}_gvar_bugs.txt`
  texts_end_time = Time.now
  puts "gvars definitions and commits messages saved in text files [#{sec_to_dhms(texts_end_time - csv_end_time)}]"

  puts "total time [#{sec_to_dhms(texts_end_time - start_time)}]"
end
puts `ruby gvar_selector.rb`
puts
puts "Total time consumed for all projects: #{sec_to_dhms(Time.now - start_time_whole)}"
puts
