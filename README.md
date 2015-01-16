# gitlab_clone  [![Gem Version](https://badge.fury.io/rb/gitlab_clone.svg)](http://badge.fury.io/rb/gitlab_clone)

## Description
gitlab_clone allows you to clone repositories from a gitlab servers group using the gitlab api. The itch I was scratching by writing this was that I was writing cookbooks for home and work. I wanted an easier way to download all of my cookbooks so that I could work with all of them at once. Anyone that has worked with chef knows that you can have a lot of repos comporising all of your cookbooks...

## Features
gitlab_clone currently features the following:

* Default cloning of all repos that are in a group called Cookbooks.
* Can pick what group you can download all the repos in that group from. 
* Will do a git pull if an existing repo has been detected. 
* Support for using either ssh or the web url to download. 
* List the repos in a group before cloning them. 

## Examples
### Get a list of repos in a group named Home:
  gitlab-clone -l -g Home
  
  \-------------------------------------------------------------------
  
  
  The following 3 repo(s) were found in the group Home.

		Repo1
		Repo2
		Repo3

\-------------------------------------------------------------------

### Clone the repos in the group named Home:
  gitlab-clone -w -g Home

\-------------------------------------------------------------------


	### Starting Web Clone Process Of The Group Home ###

	Downloading 3 repo(s) into [HOME_DIR]/projects/Home

	Repo1 directory exists, doing a git pull instead.
	Cloning Repo2...
	Cloning Repo3...

\-------------------------------------------------------------------


## Installation

    gem install gitlab_clone 
    Will give you a command named gitlab-clone to use.
