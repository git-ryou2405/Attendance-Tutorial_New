module SessionsHelper

  # 引数に渡されたユーザーオブジェクトでログインします。
  def log_in(user)
    session[:user_id] = user.id
  end
  
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end
  
  def forget(user)
    user.forget # Userモデル参照
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end
  
  # セッションと@current_userを破棄します
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  # 現在ログイン中のユーザーがいる場合オブジェクトを返します。
  def current_user
    if (user_id = session[:user_id]) # sessionにuser_id存在するなら
      @current_user ||= User.find_by(id: user_id) # id探してcurrentに情報代入する
    elsif (user_id = cookies.signed[:user_id]) # そのidがログイン中ならidを変数代入する
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token]) # userが存在し、認証でトークンが一致したら、そのままログインを続ける
        log_in user
        @current_user = user
      end
    end
  end
  
  # 現在ログイン中のユーザーがいればtrue、そうでなければfalseを返します。
  def logged_in?
    !current_user.nil?
  end
end