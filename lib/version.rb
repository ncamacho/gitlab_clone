module Version
  require "rainbow"
  def self.current
    File.open(File.expand_path('../version', __FILE__)).read
  end

   def self.version
     puts Rainbow("\n\n\----------------------------------------------------------------\n").green
     puts Rainbow("\t\tCurrent Gitlab-Clone version is #{Version::current}").green
     puts Rainbow("----------------------------------------------------------------\n\n").green
   end
end
