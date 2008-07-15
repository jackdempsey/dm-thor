class Dm < Thor

  DM_REPOS = ["extlib", "dm-core", "dm-more", "do"]
  
  desc "clone", "clone the main DM repositories"
  def clone
    if File.exists?("dm")
      puts("./dm already exists!")
      exit
    end
    require "fileutils"
    FileUtils.mkdir("dm")
    FileUtils.cd("dm")
    DM_REPOS.each {|r| system("git clone git://github.com/wycats/#{r}.git") }
  end
  
  desc 'update', 'Update your local dm repositories.  Run from inside the top-level dm directory.'
  def update
    DM_REPOS.each do |r|
      unless File.exists?(r)
        puts("#{r} missing ... did you use dm:clone to set this up?")
        exit
      end
    end
    DM_REPOS.each do |r|
      puts "Updating #{r}..."
      FileUtils.cd(r)
      system("git fetch")
      system("git checkout master")
      system("git rebase origin/master")
      FileUtils.cd("..")
    end
  end
  
  desc 'install', 'Install dm-core and dm-more'
  def install
    install = Install.new
    install.core
    install.more
  end
  
  class Gems < Thor
    desc 'wipe', 'Uninstall all RubyGems related to dm'
    def wipe
      windows = PLATFORM =~ /win32|cygwin/ rescue nil
      sudo = windows ? ("") : ("sudo")
      `gem list dm`.split("\n").each do |line|
        next unless line =~ /^(dm[^ ]+)/
        system("#{sudo} gem uninstall -a -i -x #{$1}")
      end
    end

    desc 'refresh', 'Pull fresh copies of dm and refresh all the gems'
    def refresh
      dm = Dm.new
      dm.update
      dm.install
    end

  end

  class Install < Thor
    desc 'core', 'Install dm-core'
    def core
      FileUtils.cd("dm-core")
      system("rake install")
      FileUtils.cd("..")
    end
    
    desc 'more', 'Install dm-more'
    def more
      FileUtils.cd("dm-more")
      system("rake install")
      FileUtils.cd("..")
    end
    
    desc 'extlib', 'Install extlib'
    def extlib
      FileUtils.cd("extlib")
      system("rake install")
      FileUtils.cd("..")
    end

    desc 'do', 'Install do'
    def do
      FileUtils.cd("do")
      system("rake install")
      FileUtils.cd("..")
    end
      
  end
end
