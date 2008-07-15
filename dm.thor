# Initial development done by xilef
# based on merb-thor
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
      FileUtils.cd(r){ |dir|
        system("git fetch")
        system("git checkout master")
        system("git rebase origin/master")
      }
    end
  end
  
  desc 'install', 'Install dm-core and dm-more'
  def install
    install = Install.new
    install.extlib
    install.do
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
      FileUtils.cd("dm-core"){ |dir|
        system("rake install")
      }
    end
    
    desc 'more', 'Install dm-more'
    def more
      FileUtils.cd("dm-more"){ |dir|
        system("rake install")
      }
    end
    
    desc 'extlib', 'Install extlib'
    def extlib
      FileUtils.cd("extlib"){ |dir|
        system("rake install")
      }
    end

    desc 'do', 'Install do'
    def do
      FileUtils.cd("do"){ |dir|
        system("rake install")
      }
    end
 
   class Do < Thor
     desc 'data_objects', 'Install data_objects'
     def data_objects
       FileUtils.cd("do/data_objects"){ |dir|
         system("rake install")
       }
     end

     desc 'mysql', 'Install do_mysql'
     def mysql
       FileUtils.cd("do/do_mysql"){ |dir|
         system("rake install")
       }
     end

     desc 'postgres', 'Install do_postgres'
     def postgres
       FileUtils.cd("do/do_postgres"){ |dir|
         system("rake install")
       }
     end

     desc 'sqlite3', 'Install do_sqlite3'
     def sqlite3
       FileUtils.cd("do/do_sqlite3"){ |dir|
         system("rake install")
       }
     end
     
     desc 'derby', 'Install do_derby'
     def derby
       FileUtils.cd("do/do_derby"){ |dir|
         system("rake install")
       }
     end

     desc 'hsqldb', 'Install do_hsqldb'
     def hsqldb
       FileUtils.cd("do/do_hsqldb"){ |dir|
         system("rake install")
       }
     end

   end
      
  end
end
