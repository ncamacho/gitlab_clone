class Setup
  require "rainbow"

  user_home=ENV['HOME']
  CONFIG = "#{user_home}/.gitlab_config"

### This checks to see if the json we are getting from the file is valid or not.
  def self.valid_json
    JSON.parse(File.read(CONFIG))
    return true
  rescue JSON::ParserError
    return false
  end

### Precheck to see if we have a token yet in the file
  def self.github_precheck
    if File.exist?(CONFIG) && self.valid_json
      JSON.parse(File.read(CONFIG))
      params = JSON.parse(File.read(CONFIG))
      if params["github_token"]
        return true
      else
        return false
      end
    else
      return false
    end
  end

### Prehceck to see if we dont have a file or vaild json in the file
  def self.precheck
    if !File.exist?(CONFIG) or !self.valid_json
      return false
    else
      return true
    end
  end

### This does a check to see if we have a server or token set and if we don't start the configureation process
  def self.check
    if File.exist?(CONFIG) && self.valid_json
      JSON.parse(File.read(CONFIG))
      params = JSON.parse(File.read(CONFIG))
      unless params["gitlab_server"] && params["gitlab_token"]
        puts Rainbow("It looks like either your server or token is not set properly. Do you wish to add them now? ").yellow
        answer = STDIN.gets.chomp.downcase
        if answer == "y" or answer == "yes"
          self.configure
        end
      end
    else
      puts Rainbow("You do not have a valid config file. Do you wish to create one now and configure it? ").yellow
      answer = STDIN.gets.chomp.downcase
      if answer == "y" or answer == "yes"
        self.configure
      else
        puts Rainbow("Ok, but nothing is going to work till you do....\n").yellow
      end
    end
  end

### This configures the config file for gitlab settings.
  def self.configure
    if File.exist?(CONFIG)
      JSON.parse(File.read(CONFIG))
      params = JSON.parse(File.read(CONFIG))
    else
      params = {}
    end
    puts Rainbow("What is the name of your gitlab server?\nExample: http[s]://server.domain.tld:\nServer: ").purple
    host = STDIN.gets.chomp.downcase

### Lets get/set the version we are going to use for the API
    puts Rainbow("What Gitlab API version are you using: v3 or v4? Press enter if unsure (default is v4).").purple
    check = STDIN.gets.chomp.downcase
    if check == ""
      ver = "v4"
    else
      ver = check
    end

    gitlab_host = "#{host}/api/#{ver}"
    params["gitlab_server"] = gitlab_host
    params["gitlab_server"]
    puts Rainbow("What is your token?\nExample: 3pe14gZfap:\nToken: ").purple
    params["gitlab_token"] = STDIN.gets.chomp
    puts Rainbow("Do you wish to do the Github token now too? ").purple
    answer = STDIN.gets.chomp.downcase

    if answer == "y" or answer == "yes"
      puts Rainbow("What is your Github token? ").purple
      params["github_token"] = STDIN.gets.chomp
    end

    save = JSON.generate(params)
    puts Rainbow("\n\nUpdating config file with the following:").purple
    puts Rainbow("Gitlab server: #{params["gitlab_server"]}").purple
    puts Rainbow("Gitlab token: #{params["gitlab_token"]}").purple

    if params["github_token"]
      puts Rainbow("Github token: #{params["github_token"]}").purple
    end

    puts Rainbow("\nIs this information correct? ").yellow
    answer = STDIN.gets.chomp.downcase
    if answer == "y" or answer == "yes"
      config_file = File.open(CONFIG, "w")
      config_file.write(save)
      config_file.close
      puts Rainbow("Configuration saved.\n\n").green
      exit
    else
      self.configure
    end
  end

### This configures the github token
  def self.github_configure
    if self.precheck && !self.github_precheck
      params = JSON.parse(File.read(CONFIG))
      puts Rainbow("What is your Github token?\nExample: 3pe14gZfap:\nToken: ").purple
      params["github_token"] = STDIN.gets.chomp
      save = JSON.generate(params)
      puts Rainbow("\n\nUpdating config file with the following:
            Github token: #{params["github_token"]} \n\n").purple
      puts Rainbow("Is this information correct? ").yellow
      answer = STDIN.gets.chomp.downcase
      if answer == "y" or answer == "yes"
        config_file = File.open(CONFIG, "w")
        config_file.write(save)
        config_file.close
        puts Rainbow("Configuration saved.\n\n").green
        exit
      end
    else
      puts "Whoa! Looks like we don't have configuration file yet. Do you want to create one now?"
      answer = STDIN.gets.chomp.downcase
      if answer == "y" or answer == "yes"
        self.configure
      end
    end
  end

### Get the token in the file
  def self.get_token
    unless Setup.precheck
      puts Rainbow("\n\nWhoops! Looks like we have not setup a config before...\n").yellow
      Setup.configure
    else
      JSON.parse(File.read(CONFIG))
      params = JSON.parse(File.read(CONFIG))
      return params["gitlab_token"]
    end
  end

### Get the token in the file
  def self.get_github_token
    unless Setup.github_precheck
      puts Rainbow("\n\nWhoops! Looks like we have not setup a github token yet...\n").yellow
      Setup.github_configure
    else
      JSON.parse(File.read(CONFIG))
      params = JSON.parse(File.read(CONFIG))
      return params["github_token"]
    end
  end

### Get the gitlabserver in the file
  def self.get_gitlabserver
    unless Setup.precheck
      puts Rainbow("\n\nWhoops! Looks like we have not setup a config before...\n").yellow
      Setup.configure
    else
      JSON.parse(File.read(CONFIG))
      params = JSON.parse(File.read(CONFIG))
      return params["gitlab_server"]
    end
  end
end
