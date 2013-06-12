class Gemfile < Mustache
  def requirements
    @requirements ||= {}
  end

  def gems
    a = requirements.map do |key, value|
      {name: key, version: value}
    end
  end
end
