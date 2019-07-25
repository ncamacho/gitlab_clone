class Gitlab
  require "setup"
  require "rainbow"

  def self.printhelp
    puts Rainbow("---------------------------------------------------------------------------------------\n").green
    puts Rainbow("\t\t###### Options for #{File.basename($0)} ######\n\n").green
    puts Rainbow("\t-h, --help: shows this help message").green
    puts Rainbow("\t-c, --clone: clones all repos from https://gitlab_server/groups/Cookbooks
                         into a ~/code/Cookbooks directory by default").green
    puts Rainbow("\t-ca, --clone_all: will clone all repositories ssh").green
    puts Rainbow("\t-w, --web: will clone using web protocol instead of ssh").green
    puts Rainbow("\t-wa, --web_all: will clone all repositories using web protocol instead of ssh").green
    puts Rainbow("\t-l, --list: will give you a list of repos in git (need param group)").green
    puts Rainbow("\t-la, --list_all: will give you a list of all repos in git").green
    puts Rainbow("\t-g, --group: will let you choose which gitlab group to look for repos in").green
    puts Rainbow("\t-o, --github: will allow you to clone from Github").green
    puts Rainbow("\t-n, --config: will print your current configuration settings").green
    puts Rainbow("\t-r, --reconfigure: will start the configuration process\n\n").green
    puts Rainbow("\t NOTE: You need to configure your settings first, with -r or --reconfigure.").green
    puts Rainbow("\n---------------------------------------------------------------------------------------\n\n").green
  end

  def self.list_repos(group_name)
    if (repos_list = get_repos(group_name)).empty?
      puts Rainbow("\n---\nNot repositories were found in group '#{group_name}'\n---\n").red
      return
    end
    puts Rainbow("-------------------------------------------------------------------\n").green
    puts Rainbow("\tThe following #{repos_list["projects"].length} repo(s) were found in the group '#{Rainbow(group_name).red}'.").green
    repos_list["projects"].length.times do |get|
      puts Rainbow("\t\t#{repos_list["projects"][get]["name"]}").blue
    end
    puts Rainbow("\n-------------------------------------------------------------------").green
  end

  def self.list_all_repos
    get_groups.each{|group_name,group_id| 
      list_repos(group_name)
    }
  end

  def self.clone_all(web)
    get_groups.each{|group_name,group_id| 
      clone(web, group_name)
    }
  end

  def self.clone(web, group_name)
    if (repos_list = get_repos(group_name)).empty?
      puts Rainbow("\n---\nNot repositories were found in group '#{group_name}'\n---\n").red
      return
    end

    repos_dir = "#{Setup.get_backup_dir}/#{group_name}"

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
    puts Rainbow("-------------------------------------------------------------------\n").green
    puts Rainbow("\t### Starting #{message} Clone Process Of The Group #{group_name} ###").green
    puts Rainbow("\tDownloading #{repos_list["projects"].length} repo(s) into #{repos_dir}\n").green

    repos_list["projects"].length.times do |get|
      repo_name = repos_list["projects"][get]["name"]
      repo = repos_list["projects"][get]["#{repo_location}"]
      dir = repos_list["projects"][get]["name"]
      repo_dir = "#{repos_dir}/#{dir}"

      if File.directory?("#{repo_dir}")
        puts Rainbow("\t\"#{repo_name}\" repo directory exists, doing a git pull instead.").purple
        Dir.chdir("#{repo_dir}")
        g = Git.init
        g.pull
      else
        puts Rainbow("\tCloning repo \"#{repo_name}\"...").blue
        Git.clone("#{repo}", "#{repo_dir}")
      end
    end
    puts Rainbow("\n-------------------------------------------------------------------\n").green
  end

  def self.get_repos(group_name)
    group_id = get_groups[group_name]
    string = HTTParty.get("#{Setup.get_gitlabserver}/groups/#{group_id}", :headers => {"PRIVATE-TOKEN" => "#{Setup.get_token}" }, :verify => false).to_json
    rep = JSON.parse(string)
  end

  def self.get_groups
    string = HTTParty.get("#{Setup.get_gitlabserver}/groups?all_available=true", :headers => {"PRIVATE-TOKEN" => "#{Setup.get_token}" }, :verify => false).to_json
    api_ids = JSON.parse(string)
    group_ids = {}
    api_ids.each do |id|
      group_ids["#{id["name"]}"] = id["id"]
    end
    return group_ids
  end

  def self.config
    puts Rainbow("################### Current Gitlab Configuration ###################").green
    puts
    puts Rainbow("\tCurrent Gitlab token:\t\t #{Setup.get_token}").green
    puts Rainbow("\tCurrent Gitlab server address:\t #{Setup.get_gitlabserver}").green
    if Setup.github_precheck
      puts Rainbow("\tCurrent Github token:\t\t #{Setup.get_github_token}").green
    end
    puts Rainbow("\tCurrent backup directory:\t\t #{Setup.get_backup_dir}").green
    puts
    puts Rainbow("#######################################################################").green
  end

end
