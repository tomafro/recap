class ExampleGem
  attr_reader :name, :version

  def initialize(name, version)
    @name = name
    @version = version
    @binary = Binary.new(self)
    @gemspec = Gemspec.new(self)
  end

  def package_to(path)
    FileUtils.mkdir_p(path)
    Dir.mktmpdir do |tmp|
      FileUtils.chdir tmp do
        FileUtils.mkdir "bin"
        File.write "#{name}.gemspec", @gemspec.to_s
        File.write "bin/#{name}", @binary.to_s
        File.write "Rakefile", 'require "bundler/gem_tasks"'
        `rake build`
        packaged = "#{@name}-#{version}.gem"
        File.write "#{path}/#{packaged}", File.read("pkg/#{packaged}")
      end
    end
  end

  class Binary < Mustache
    def initialize(gem)
      @gem = gem
    end

    def version
      @gem.version
    end
  end

  class Gemspec < Mustache
    def initialize(gem)
      @gem = gem
    end

    def name
      @gem.name
    end

    def version
      @gem.version
    end
  end
end
