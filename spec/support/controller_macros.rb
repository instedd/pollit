module ControllerMacros
  def before_each_sign_in_as_new_user
    before(:each) do
      request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in User.make
    end
  end
end
