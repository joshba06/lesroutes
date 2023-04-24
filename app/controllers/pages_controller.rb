class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home]

  def home
    if browser.device.mobile?
      render variants: [:mobile]
    else
      render variants: [:desktop]
    end
  end
end
