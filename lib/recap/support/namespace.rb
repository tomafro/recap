require 'capistrano'
require 'recap/support/capistrano_extensions'

module Recap::Support::Namespace
  def self.default_config
    @default_config
  end

  def self.default_config=(config)
    @default_config = config
  end

  if Capistrano::Configuration.instance
    self.default_config = Capistrano::Configuration.instance(:must_exist)
  end

  def capistrano_definitions
    @capistrano_definitions ||= []
  end

  def namespace(name, &block)
    capistrano_definitions << Proc.new do
      namespace name do
        instance_eval(&block)
      end
    end

    load_into(Recap::Support::Namespace.default_config) if Recap::Support::Namespace.default_config
  end

  def load_into(configuration)
    configuration.extend(self)
    capistrano_definitions.each do |definition|
      configuration.load(&definition)
    end
  end
end