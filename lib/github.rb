class Github
	TOKEN=ENV['github_token']
	SERVER="https://api.github.com"
	HOME=ENV['HOME']


  def self.list_repos(group_name)
    repos_list = get_repos(group_name)
    puts "-------------------------------------------------------------------\n"
    puts "\tThe following #{repos_list.count} repo(s) were found in the Org #{group_name}.\n\n"
    repos_list.each do |get|
      puts "\t\t#{get["name"]}"
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
      repo_location = 'clone_url'
      message = "Web"
    else
      repo_location = 'ssh_url'
      message = "Ssh"
    end
    puts "-------------------------------------------------------------------\n"
    puts "\t### Starting #{message} Clone Process Of The Org #{group_name} ###\n\n"
    puts "\tDownloading #{repos_list.count} repo(s) into #{repos_dir}\n\n"

    repos_list.each do |get|
      repo_name = get["name"]
      repo = get["#{repo_location}"]
      dir = get["name"]
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
    string = HTTParty.get("#{SERVER}/orgs/#{group_name}/repos", :headers => {"Authorization" => "token #{TOKEN}", 'User-Agent' => 'HTTParty'},  :verify => false).to_json
    rep = JSON.parse(string)
  end
end
