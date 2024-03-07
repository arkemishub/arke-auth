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

  def on_unit_delete(_arke, unit) do
    user = QueryManager.get_by(project: :arke_system, arke_id: :user, id: unit.data.arke_system_user)
    QueryManager.delete(:arke_system, user)
    {:ok, unit}
  end
  def before_unit_delete(_arke, unit), do: {:ok, unit}

  # Temporary code until all arke are managed on database
  def get_permission(member, arke) do
    list_sytem_arke = Enum.map(ArkeManager.get_all(:arke_system), fn {k, v} -> k  end)
    if arke.id in list_sytem_arke do
      if member.arke_id == :super_admin do
        {:ok, permission_dict(%{filer: nil, get: true, put: true, post: true, delete: true})}
      else
        {:error, nil}
      end
    else
      handle_get_permission(member, arke)
    end
  end

  defp handle_get_permission(member, %{metadata: %{project: project}}=arke) do
    arke_link = ArkeManager.get(:arke_link, :arke_system)
    arke_member_public = QueryManager.get_by(project: project, arke_id: "ake", id: "member_public")
    parent_id_list = if member == nil, do: ["member_public"], else: ["member_public", Atom.to_string(member.arke_id)]
    permissions = QueryManager.query(project: project, arke: arke_link.id) |> QueryManager.where(parent_id__in: parent_id_list, child_id: Atom.to_string(arke.id), type: "permission") |> QueryManager.all
    member_public_permission =
      case Enum.find(permissions, fn p -> p.data.parent_id == "member_public" end) do
        nil -> permission_dict()
        u ->
          permission_dict(u.metadata)
      end

    member_permission =
      case Enum.find(permissions, fn p -> p.data.parent_id != "member_public" end) do
        nil -> permission_dict()
        u ->
          permission_dict(u.metadata)
      end

    data = Map.merge(member_public_permission, member_permission, fn _k, v1, v2 ->
      if v1, do: v1, else: v2
    end) |> permission_dict
    if Map.to_list(data) == [] do
      {:error, nil}
    else
      {:ok, data}
    end
  end

  defp permission_dict(data \\ %{}) do
    filter = Map.get(data, "filter", nil)
    get = Map.get(data, "get", false)
    put = Map.get(data, "put", false)
    delete = Map.get(data, "delete", false)
    post = Map.get(data, "post", false)
    child_only = Map.get(data, "child_only", false)

    filter = Map.get(data, :filter, filter)
    get = Map.get(data, :get, get)
    put = Map.get(data, :put, put)
    delete = Map.get(data, :delete, delete)
    post = Map.get(data, :post, post)
    child_only = Map.get(data, :child_only, child_only)

    %{filter: filter, get: get, put: put, delete: delete, post: post, child_only: child_only}
  end
end


# arke remote: true do
#   parameter(:nickname, :string, required: false)
#   parameter(:first_name, :string, required: false)
#   parameter(:last_name, :string, required: false)
#   parameter(:fiscal_code, :string, required: false)
#   parameter(:birth_date, :string, required: false)
#   parameter(:address, :dict, required: false)
#   parameter(:user_id, :string, required: true)
# end
