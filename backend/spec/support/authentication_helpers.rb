# frozen_string_literal: true

module AuthenticationHelpers
  def sign_in(user)
    post '/login', params: { session: { account_name: user.account_name, password: 'password_password' } }
  end
end
