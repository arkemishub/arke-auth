# Copyright 2023 Arkemis S.r.l.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

defmodule ArkeAuth.Core.User do
  import Comeonin.Bcrypt, only: [hashpwsalt: 1, checkpw: 2]
  alias ArkeAuth.Core.User
  alias ArkeAuth.Boundary.Validators

  alias Arke.Utils.ErrorGenerator, as: Error

  @moduledoc """
  Documentation for `User`.
  """
  use Arke.System

  arke do
    parameter(:username, :string, required: true, unique: true)
    parameter(:password_hash, :string, required: true)

    parameter(:type, :string,
      required: true,
      values: ["customer", "admin", "super_admin"],
      multiple: false
    )

    parameter(:first_name, :string, required: false)
    parameter(:last_name, :string, required: false)
    parameter(:fiscal_code, :string, required: false)
    parameter(:birth_date, :string, required: false)
    parameter(:address, :dict, required: false)
    parameter(:phone_number, :string, required: false)
    parameter(:first_access, :boolean, required: false, default_boolean: false)
    parameter(:last_login, :string, required: false)
    parameter(:environment, :string, required: false)
  end

  def before_load(data, :create) do
    # IF map has arke_id means it has been retrieved from db
    case Map.get(data, :arke_id) do
      nil ->
        with {:ok, pwd} <- Validators.check_user_password(data) do
          new_data = Map.put(data, :password_hash, hashpwsalt(pwd)) |> Map.delete(:password)
          {:ok, new_data}
        else
          {:error, msg} -> {:error, msg}
        end

      _ ->
        {:ok, data}
    end
  end

  def before_load(data, _persistence_fn), do: {:ok, data}

  ########
  # FUNCTIONS
  #######

  @doc """
  Check if the given password is right

  ## Parameters
    - user => %Arke.Core.Unit{} => user struct
    - pwd => string => password to check

  ## Return
      {:ok, %Arke.Core.Unit{}}
  """
  @spec check_password(user :: ArkeAuth.Core.Unit.t(), pwd :: String.t()) ::
          {:ok, ArkeAuth.Core.Unit.t()} | Arke.Utils.ErrorGenerator.t()
  def check_password(%{data: data} = user, pwd) do
    case checkpw(pwd, data.password_hash) do
      true -> {:ok, user}
      false -> Error.create(:auth, "invalid password")
    end
  end

  @doc """
  Update the user password

  ## Parameters
    - user => %Arke.Core.Unit{} => user struct
    - new_pwd => string => password to check

  ## Return
      {:ok, %Arke.Core.Unit{}}
  """
  @spec update_password(user :: ArkeAuth.Core.Unit.t(), new_pwd :: String.t()) ::
          {:ok, ArkeAuth.Core.Unit.t()} | Arke.Utils.ErrorGenerator.t()
  def update_password(user, new_pwd) do
    Arke.QueryManager.update(user, password_hash: hashpwsalt(new_pwd))
  end
end
