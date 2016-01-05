require 'csv'
require 'envyable'

def get_project_age dir
 `gvar --project-inf --dirs="['#{dir}']" --rev-range=master`.strip
end

def get_all_commit_num dir 
 `gvar --list-shas --dirs="['#{dir}']" --rev-range=master | wc -l`.strip
end

def get_all_bf_commits_num dir                                                   
  `gvar --count-all-bugs --dirs="['#{dir}']" --rev-range=master`.strip
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
CSV.open('results/data_gvar.csv', "w+") {|row| row << headers }

File.open('config/projects_to_analyze.config').each_line do |line|
  project, dir = line.split
  puts "------------------> #{project}"

  wd = cwd + "/projects/" + project

  begin
    Dir.chdir wd
    `git checkout master`
    `gvar --store-commits --db=#{PREFIX}_#{project} --dirs="['#{dir}']" --rev-range=master`
    age = get_project_age(dir)
    commits = get_all_commit_num(dir)
    bf_commits = get_all_bf_commits_num(dir)
  ensure
    `git checkout master`
    Dir.chdir cwd
  end
  gvars, gvars_rel_bf, gvars_bf_count, bfs_rel_gvar, gvars_removed = get_extra_data(project)

  CSV.open('results/data_gvar.csv', "a+") do |row|
    row << [project, "master", dir, age, commits, bf_commits, gvars, bfs_rel_gvar, gvars_rel_bf, gvars_bf_count, gvars_removed]
  end

  # Create a csv file with the definition of all gvars in the project
  puts `mongoexport --db i_#{project} --collection globals | ruby get_gvar_def.rb #{project}`

  # Write in a file all bugfix commits messages and patches ordered by gvars
  `mongoexport --db i_#{project} --collection globals | ruby get_bugfix_commits_info_by_gvar.rb projects/#{project}/ > results/#{project}_gvar_bugs.txt`
end
