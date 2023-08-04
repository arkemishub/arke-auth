defmodule ArkeAuth.OauthProvider.Google do

  use Arke.System


  arke id: :oauth_google do
    group(:oauth_provider,
      label: "Oauth provider",
      description: "Group with all the oauth provider supported"
    )

    parameter(:first_name, :string, required: false)
    parameter(:last_name, :string, required: false)
    parameter(:email, :string, required: false)
    parameter(:oauth_id, :string, required: true)
  end

  def setup(data) do
    ArkeAuth.Utils.SetupOAuth.setup(data)
    :ok
  end
end
