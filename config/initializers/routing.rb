class ActionDispatch::Routing::Mapper

  def scope_if(condition, s, opts)
    if condition
      self.scope s, opts do
        yield
      end
    else
      yield
    end
  end

end