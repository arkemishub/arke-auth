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

defmodule ArkeAuth.Core.Member do
  alias Arke.QueryManager
  alias ArkeAuth.Core.Member
  alias Arke.Boundary.ArkeManager

  @moduledoc """
  Documentation for `Member`.
  """
  use Arke.System.Group

  group id: "arke_auth_member" do
  end



  def on_unit_load(arke, data, _persistence_fn), do: {:ok, data}
  def before_unit_load(_arke, data, _persistence_fn), do: {:ok, data}
  def on_unit_validate(_arke, unit), do: {:ok, unit}

  #TODO Handle user validation (if user exists)
  def before_unit_validate(_arke, %{data: %{arke_system_user: arke_system_user}}=unit) when is_binary(arke_system_user) do
    {:ok, unit}
  end
  #TODO Handle user validation (if user already exists and user data validation)
  def before_unit_validate(_arke, %{data: %{arke_system_user: arke_system_user}}=unit) when is_map(arke_system_user) do
    {:ok, unit}
  end

  def on_unit_create(_arke, unit), do: {:ok, unit}

  def before_unit_create(_arke, %{data: %{arke_system_user: arke_system_user}}=unit) when is_map(arke_system_user) do

    arke_user = ArkeManager.get(:user, :arke_system)

    user_data = Enum.map(arke_system_user, fn {key, value} -> {String.to_existing_atom(key), value} end)
    Arke.QueryManager.create(:arke_system, arke_user, user_data)
    |> case do
      {:ok, user} ->
        unit = Arke.Core.Unit.update(unit, arke_system_user: user.id)
        {:ok, unit}
      {:error, error} ->
        {:error, error}
    end
  end
  def before_unit_create(_arke, unit), do: {:ok, unit}

  def on_unit_struct_encode(unit, _), do: {:ok, unit}
  def on_unit_update(_arke, unit), do: {:ok, unit}

  def before_unit_update(_arke, %{data: %{arke_system_user: arke_system_user}}=unit) when is_map(arke_system_user) do

    arke_user = ArkeManager.get(:user, :arke_system)

    user_data = Enum.map(arke_system_user, fn {key, value} -> {String.to_existing_atom(key), value} end)
    # user = QueryManager.get_by(project: :arke_system, arke_id: :user, id: )
    QueryManager.update(:arke_system, %{}, user_data)
    |> case do
      {:ok, user} ->
        unit = Arke.Core.Unit.update(unit, arke_system_user: user.id)
        {:ok, unit}
      {:error, error} ->
        {:error, error}
    end
  end
  def before_unit_update(_arke, unit), do: {:ok, unit}

  def on_unit_delete(_arke, unit), do: {:ok, unit}
  def before_unit_delete(_arke, unit), do: {:ok, unit}

  # Temporary code until all arke are managed on database
  def get_permission(member, arke) do
    list_sytem_arke = Enum.map(ArkeManager.get_all(:arke_system), fn {k, v} -> k  end)
    IO.inspect({arke.id, list_sytem_arke, member.arke_id})
    if arke.id in list_sytem_arke do
      if member.arke_id == :super_admin do
        {:ok, permission_dict(nil, true, true, true, true)}
      else
        {:error, nil}
      end
    else
      handle_get_permission(member, arke)
    end
  end

  defp handle_get_permission(%{metadata: %{project: project}}=member, arke) do
    arke_link = ArkeManager.get(:arke_link, :arke_system)
    with %Arke.Core.Unit{} = link <-
      Arke.QueryManager.query(project: project, arke: arke_link)
      |> Arke.QueryManager.filter(:parent_id, :eq, member.arke_id, false)
      |> Arke.QueryManager.filter(:child_id, :eq, Atom.to_string(arke.id), false)
      |> Arke.QueryManager.filter(:type, :eq, "permission", false)
      |> Arke.QueryManager.one(),
    do: {:ok, permission_dict(
      Map.get(link.metadata, "filter", nil),
      Map.get(link.metadata, "get", nil),
      Map.get(link.metadata, "put", nil),
      Map.get(link.metadata, "delete", nil),
      Map.get(link.metadata, "post", nil)
      )},
    else: (_ -> {:error, nil})
  end

  defp permission_dict(filter, get, put, delete, post), do: %{filter: filter, get: get, put: put, delete: delete, post: post}
end


# arke do
#   parameter(:nickname, :string, required: false)
#   parameter(:first_name, :string, required: false)
#   parameter(:last_name, :string, required: false)
#   parameter(:fiscal_code, :string, required: false)
#   parameter(:birth_date, :string, required: false)
#   parameter(:address, :dict, required: false)
#   parameter(:user_id, :string, required: true)
# end
