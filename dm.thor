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
    DM_REPOS.each {|r| system("git clone git://github.com/sam/#{r}.git") }
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
      FileUtils.cd(r) do
        system %{
          git fetch
          git checkout master
          git rebase origin/master
        }
      end
    end
  end

  desc 'install', 'Install extlib, dm-core and dm-more'
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
      check_for_dir("dm-core")
      install_gem("dm-core")
    end

    desc 'more', 'Install dm-more'
    def more
      check_for_dir("dm-more")    
      install_gem("dm-more")
    end

    desc 'extlib', 'Install extlib'
    def extlib
      check_for_dir("extlib")
      install_gem("extlib")
    end

    desc 'do', 'Install do'
    def do
      check_for_dir("do")      
      install_gem("do")
    end

    class Do < Thor

      desc 'data_objects', 'Install data_objects'
      def data_objects
        install_gem("do/data_objects")
      end

      desc 'mysql', 'Install do_mysql'
      def mysql
        install_gem("do/do_mysql")
      end

      desc 'postgres', 'Install do_postgres'
      def postgres
        install_gem("do/do_postgres")
      end

      desc 'sqlite3', 'Install do_sqlite3'
      def sqlite3
        install_gem("do/do_sqlite3")
      end

      desc 'derby', 'Install do_derby'
      def derby
        install_gem("do/do_derby")
      end

      desc 'hsqldb', 'Install do_hsqldb'
      def hsqldb
        install_gem("do/do_hsqldb")
      end
      
      desc "jdbc", "Install jdbc-support and jdbc_drivers"
      def jdbc
        install_gem("do/jdbc-support")
        install_gem("do/jdbc_drivers")
      end
      
    end

  end
end


def install_gem(gem)
  FileUtils.cd(gem) { system("rake install") }
end

def check_for_dir(dir)
  unless File.exists?(dir)
    puts "Error : Can't see '#{dir}' dir. Make sure you're in the correct directory and try again."
    exit
  end
end

