require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'
require 'fileutils'
include FileUtils

NAME = "camping"
REV = (`#{ENV['GIT'] || "git"} rev-list HEAD`.split.length + 1).to_s rescue nil
VERS = ENV['VERSION'] || ("1.9" + (REV ? ".#{REV}" : ""))
CLEAN.include ['**/.*.sw?', '*.gem', '.config', 'test/test.log', '.*.pt']
RDOC_OPTS = ['--quiet', '--title', "Camping, the Documentation",
    "--opname", "index.html",
    "--line-numbers", 
    "--main", "README",
    "--inline-source"]

def set_version(name)
  p = 'lib/camping.rb'
  p2 = "camping-#{name}.rb"
  if File.exists?(p)
    if File.symlink?(p)
      File.unlink(p)
    else
      STDERR.puts "** #{p} already exists. Remove it and re-run the command"
      exit 1
    end
  end
  File.symlink(p2, p)
end

desc "Packages up Camping."
task :default => [:check]
task :package => [:clean, "version:short"]

task :doc => ["version:long", :rdoc, :rdoc_extras]

Rake::RDocTask.new do |rdoc|
    rdoc.rdoc_dir = 'doc/rdoc'
    rdoc.options += RDOC_OPTS
    rdoc.template = "extras/flipbook_rdoc.rb"
    rdoc.main = "README"
    rdoc.title = "Camping, the Documentation"
    rdoc.rdoc_files.add ['README', 'CHANGELOG', 'COPYING', 'lib/camping.rb', 'lib/camping/*.rb']
end

task :rdoc_extras do
  cp "extras/Camping.gif", "doc/rdoc/"
  cp "extras/permalink.gif", "doc/rdoc/"
end

desc "Sets development environment"
task :devel => ['version:long']

namespace :version do
  task :short do set_version('shortshort') end
  task :long do set_version('unabridged') end
end

namespace :publish do
  desc "Copies rdoc to rubyforge"
  task :rdoc => "doc" do
    sh %{scp -r doc/rdoc/* #{ENV['USER']}@rubyforge.org:/var/www/gforge-projects/camping/}
  end
end

spec =
    Gem::Specification.new do |s|
        s.name = NAME
        s.version = VERS
        s.platform = Gem::Platform::RUBY
        s.has_rdoc = true
        s.extra_rdoc_files = ["README", "CHANGELOG", "COPYING"]
        s.rdoc_options += RDOC_OPTS + ['--exclude', '^(examples|extras)\/', '--exclude', 'lib/camping.rb']
        s.summary = "minature rails for stay-at-home moms"
        s.description = s.summary
        s.author = "why the lucky stiff"
        s.email = 'why@ruby-lang.org'
        s.homepage = 'http://code.whytheluckystiff.net/camping/'
        s.executables = ['camping']

        s.add_dependency('activesupport', '>=1.3.1')
        s.add_dependency('markaby', '>=0.5')
        s.add_dependency('metaid')
        s.required_ruby_version = '>= 1.8.2'

        s.files = %w(COPYING README Rakefile) +
          Dir.glob("{bin,doc,test,lib,extras}/**/*") + 
          Dir.glob("ext/**/*.{h,c,rb}") +
          Dir.glob("examples/**/*.rb") +
          Dir.glob("tools/*.rb")
        
        s.require_path = "lib"
        # s.extensions = FileList["ext/**/extconf.rb"].to_a
        s.bindir = "bin"
    end

omni =
    Gem::Specification.new do |s|
        s.name = "camping-omnibus"
        s.version = VERS
        s.platform = Gem::Platform::RUBY
        s.summary = "the camping meta-package for updating ActiveRecord, Mongrel and SQLite3 bindings"
        s.description = s.summary
        %w[author email homepage].each { |x| s.__send__("#{x}=", spec.__send__(x)) }

        s.add_dependency('camping', "=#{VERS}")
        s.add_dependency('activerecord')
        s.add_dependency('sqlite3-ruby', '>=1.1.0.1')
        s.add_dependency('mongrel')
        s.add_dependency('acts_as_versioned')
        s.add_dependency('RedCloth')
    end

Rake::GemPackageTask.new(spec) do |p|
    p.need_tar = true
    p.gem_spec = spec
end

Rake::GemPackageTask.new(omni) do |p|
    p.gem_spec = omni
end

task :install do
  sh %{rake package}
  sh %{sudo gem install pkg/#{NAME}-#{VERS}}
end

task :uninstall => [:clean] do
  sh %{sudo gem uninstall #{NAME}}
end

Rake::TestTask.new(:test) do |t|
  t.test_files = FileList['test/test_*.rb']
#  t.warning = true
#  t.verbose = true
end

desc "Compare camping and camping-unabridged parse trees"
task :diff do
  if `which parse_tree_show`.strip.empty?
    STDERR.puts "ERROR: parse_tree_show missing : `gem install ParseTree`"
    exit 1
  end

  sh "parse_tree_show lib/camping.rb > .camping.pt"
  sh "parse_tree_show lib/camping-unabridged.rb > .camping-unabridged.pt"
  sh "diff -u .camping-unabridged.pt .camping.pt | less"
end

task :ruby_diff do
  require 'ruby2ruby'
  c = Ruby2Ruby.translate(File.read("lib/camping-shortshort.rb"))
  n = Ruby2Ruby.translate(File.read("lib/camping-unabridged.rb"))
  
  File.open(".camping-unabridged.rb.rb","w"){|f|f<<c}
  File.open(".camping-shortshort.rb.rb","w"){|f|f<<n}
  
  sh "diff -u .camping-unabridged.rb.rb .camping-shortshort.rb.rb | less"
end

task :check => ["check:valid", "check:size", "check:lines"]
namespace :check do

  desc "Check source code validity"
  task :valid do
    ruby "-rubygems", "-w", "lib/camping-unabridged.rb"
    ruby "-rubygems", "-w", "lib/camping-shortshort.rb"
  end

  SIZE_LIMIT = 4096
  desc "Compare camping sizes to unabridged"
  task :size do
    FileList["lib/camping*.rb"].each do |path|
      if File.symlink?(path)
        puts "%21s : -> %s" % [File.basename(path), File.readlink(path)]
      else
        s = File.size(path)
        puts "%21s : % 6d % 4d%" % [File.basename(path), s, (100 * s / SIZE_LIMIT)]
      end
    end
    if File.size("lib/camping-shortshort.rb") > SIZE_LIMIT
      STDERR.puts "lib/camping.rb: file is too big (> #{SIZE_LIMIT})"
    end
  end

  desc "Verify that line lenght doesn't exceed 80 chars for camping.rb"
  task :lines do
    i = 1
    File.open("lib/camping-shortshort.rb").each_line do |line|
      if line.size > 81 # 1 added for \n
        STDERR.puts "lib/camping-shortshort.rb:#{i}: line too long (#{line[-10..-1].inspect})"
      end
      i += 1
    end
  end

end
