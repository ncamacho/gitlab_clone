class Jtc
  TOKEN=ENV['gitlab_token']
  SERVER=ENV['gitlab_server']
  HOME=ENV['HOME']


  def self.printhelp
    puts "-------------------------------------------------------------------\n\n"
    puts "\t\t####  Options for gitlab-clone  ####\n\n"
    puts "\t-h, --help: shows this help message"
    puts "\t-c, --clone: clones all repos from http[s]://[server_name]/groups/Cookbooks
                         into a ~/projects/Cookbooks directory by default"
    puts "\t-g, --group: will let you choose which gitlab group to look for repos in"
    puts "\t-l, --list: will give you a list of repos in git\n\n"
    puts "\t-w, --web: will clone using web protocol instead of ssh"

    puts "\t NOTE: You need to set gitlab_server and gitlab_token for this to work."
    puts "\t\texample: export gitlab_server=\"http[s]://[server_name]/api/v3\""
    puts "\t\t\t export gitlab_token=\"secret_token\""
    puts "-------------------------------------------------------------------\n\n"
  end

  def self.list_repos(group_name)
    repos_list = get_repos(group_name)
    puts "-------------------------------------------------------------------\n"
    puts "\tThe following #{repos_list["projects"].length} repo(s) were found in the group #{group_name}.\n\n"
    repo_list["projects"].length.times do |get|
      puts "\t\t#{repo_list["projects"][get]["name"]}"
    end
    puts "\n-------------------------------------------------------------------"
  end

  def self.clone(web, group_name)
    repos_list = get_repos(group_name)
    repos_dir = "#{HOME}/projects/#{group_name}"

    if File.directory?("#{repos_dir}")
      FileUtils::mkdir_p repos_dir
    end
    
    if web == 1
      repo_location = 'http_url_to_repo'
      message = "Web"
    else 
      repo_location = 'ssh_url_to_repo'
      message = "Ssh"
    end
    puts "-------------------------------------------------------------------\n"
    puts "\t### Starting #{message} Clone Process Of The Group #{group_name} ###\n\n"
    puts "\tDownloading #{repos_list["projects"].length} repo(s) into #{repos_dir}\n\n"

    repos_list["projects"].length.times do |get|
      repo_name = repos_list["projects"][get]["name"]
      repo = repos_list["projects"][get]["#{repo_location}"]
      dir = repos_list["projects"][get]["name"]
      repo_dir = "#{repos_dir}/#{dir}"

      if File.directory?("#{repo_dir}")
        puts "\t#{repo_name} directory exists, doing a git pull instead."
        Dir.chdir("#{repo_dir}")
        g = Git.init
        g.pull
      else
        puts "\tCloning #{repo_name}..."
        Git.clone("#{repo}", "#{repo_dir}") 
      end
    end
    puts "-------------------------------------------------------------------\n"
  end

  def self.get_repos(group_name)
    group_id = get_groups[group_name]
    string = HTTParty.get("#{SERVER}/groups/#{group_id}", :headers => {"PRIVATE-TOKEN" => "#{TOKEN}" }, :verify => false).to_json
    rep = JSON.parse(string)
  end

  def self.get_groups
    string = HTTParty.get("#{SERVER}/groups", :headers => {"PRIVATE-TOKEN" => "#{TOKEN}" }, :verify => false).to_json
    api_ids = JSON.parse(string)
    group_ids = {}
    api_ids.each do |id|
      group_ids["#{id["name"]}"] = id["id"]
    end
    return group_ids
  end

  def self.version
      puts "----------------------------------------------------------------\n\n"
      puts "\t\tCurrent gitlab-clone verison is #{Version::VERSION}\n"
      puts "----------------------------------------------------------------\n\n"
  end

end
