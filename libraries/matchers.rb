if defined?(ChefSpec)
  def install_playframework(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:playframework, :install, resource_name)
  end
end
