defmodule ArkeAuth.ResetPasswordToken do
  alias ArkeAuth.ResetPasswordToken
  import Comeonin.Bcrypt, only: [hashpwsalt: 1, checkpw: 2]

  @moduledoc """
             Documentation for `ResetPasswordToken`.
             """ && false

  use Arke.System

  arke do
    parameter(:token, :string, label: "Token", required: true, unique: true)
    parameter(:user_id, :string, label: "User Id", required: true)
    parameter(:expiration, :datetime, required: true)
  end

  def before_load(data, :create) do
    # IF map has arke_id means it has been retrieved from db (delete if expiration is past by ??)
    case Map.get(data, :arke_id) do
      nil ->
        create_token(data)

      _ ->
        {:ok, data}
    end
  end

  def before_load(data, _persistence_fn), do: {:ok, data}

  defp create_token(data) do
    token = :crypto.strong_rand_bytes(22) |> Base.url_encode64(case: :lower, padding: false)
    user_id = Map.fetch!(data, :user_id)
    {:ok,
     %{
       token: token,
       expiration: Arke.DatetimeHandler.shift_datetime(weeks: 2),
       user_id: user_id
     }}
  end
end
