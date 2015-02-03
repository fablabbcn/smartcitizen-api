module EnvVars

  def set_env_var(name, value)
    allow(ENV).to receive(:[]).with(name).and_return(value)
  end

end
