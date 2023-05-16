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

# defmodule ArkeAuth.Boundary.PermissionManager do
#   alias ArkeAuth.Core.Guardian

#   @moduledoc """
#              Module to manage the permission of a user
#              """ && false
#   @record_fields [:id, :data, :configuration, :inserted_at, :updated_at]

#   @repo List.first(Application.get_env(@app, :ecto_repos))

#   import Ecto.Query
#   alias Arke.Boundary.ArkeManager
#   alias Arke.QueryManager

#   def add_node(
#         %Arke.Core.Unit{} = parent,
#         %Arke.Core.Unit{} = child,
#         %ArkeAuth.Boundary.PermissionStruct{} = permission,
#         configuration \\ %{}
#       )
#       when parent.arke.id == :user or parent.arke.id == :company do
#     parent_id = get_node_id(parent)
#     child_id = get_node_id(child)
#     arke_auth = ArkeManager.get(:arke_auth, :arke_system)
#     ## control is inverted because if a record already exist it should not be created again
#     with {:error, _} <- check_existing_node(parent_id, child_id),
#          do:
#            QueryManager.create(arke_auth,
#              parent_id: parent_id,
#              child_id: child_id,
#              type: Map.from_struct(permission),
#              configuration: configuration
#            ),
#          else: ({:ok, msg} -> {:error, msg})
#   end

#   def add_node(_, _, _, _), do: {:error, "invalid parameters"}

#   defp check_existing_node(parent_id, child_id) do
#     repo = @repo

#     query =
#       from(a in "arke_auth",
#         select: count("*"),
#         where: fragment("parent_id = ? and child_id = ?", ^parent_id, ^child_id)
#       )

#     case repo.one(query) > 0 do
#       true -> {:ok, "record found"}
#       false -> {:error, "no records found"}
#     end
#   end

#   def get_nodes(%{arke: arke, data: data} = _unit, depth \\ 500, direction \\ :child, opts \\ []) do
#     repo = @repo

#     query =
#       from(a in "arke_unit",
#         left_join:
#           cte in fragment(
#             """
#             (
#               WITH RECURSIVE tree(depth, parent_id, type, child_id, configuration) AS (
#                 SELECT 0, parent_id, type, child_id, configuration FROM arke_auth WHERE parent_id = ?
#                 UNION SELECT
#                   depth + 1,
#                   arke_auth.parent_id,
#                   arke_auth.type,
#                   arke_auth.child_id,
#                   arke_auth.configuration
#                 FROM
#                   arke_auth JOIN tree
#                   ON arke_auth.parent_id = tree.child_id
#                 WHERE
#                  depth < ?
#               )
#               SELECT * FROM tree ORDER BY depth
#             )
#             """,
#             ^data.id,
#             ^depth
#           ),
#         where: a.id == cte.child_id,
#         select: %{
#           id: a.id,
#           data: a.data,
#           unit_configuration: a.configuration,
#           inserted_at: a.inserted_at,
#           updated_at: a.updated_at,
#           depth: cte.depth,
#           link_configuration: cte.configuration
#         }
#       )

#     repo.all(query)
#   end

#   def get_shared_nodes(user) do
#     user_id = get_node_id(user)
#     repo = @repo

#     query =
#       from(p in "arke_auth",
#         select: p.child_id,
#         where: fragment("(type ->> 'shared_by') = ?", ^user_id)
#       )

#     repo.all(query)
#   end

#   def delete_node(parent, child) do
#     parent_id = get_node_id(parent)
#     child_id = get_node_id(child)
#     repo = @repo

#     query =
#       from(p in "arke_auth",
#         where: fragment("parent_id = ? and child_id = ?", ^parent_id, ^child_id)
#       )

#     case repo.delete_all(query) do
#       {0, nil} -> {:error, "no record deleted"}
#       {num, nil} -> {:ok, "#{num} record deleted"}
#     end
#   end

#   def get_permitted_nodes(user, child, permission \\ :read, opts \\ []) do
#     parent_id = get_node_id(user)
#     child_id = get_node_id(child)
#     repo = @repo

#     query =
#       from(p in "arke_auth",
#         select: count("*"),
#         where:
#           fragment(
#             "(type ->> ?)::boolean is true and parent_id = ? and child_id = ?",
#             ^Atom.to_string(permission),
#             ^parent_id,
#             ^child_id
#           )
#       )

#     case repo.one(query) > 0 do
#       true -> {:ok, "user authorized"}
#       false -> {:error, "user not authorized"}
#     end
#   end

#   defp raw_link_query() do
#     dynamic(
#       [q],
#       fragment(
#         """
#         (
#           WITH RECURSIVE tree(depth, parent_id, type, child_id, configuration) AS (
#             SELECT 0, parent_id, type, child_id, configuration FROM arke_auth WHERE child_id = ?
#             UNION SELECT
#               depth + 1,
#               arke_auth.parent_id,
#               arke_auth.type,
#               arke_auth.child_id,
#               arke_auth.configuration
#             FROM
#               arke_auth JOIN tree
#               ON arke_auth.child_id = tree.parent_id
#           )
#           SELECT * FROM tree ORDER BY depth
#         )
#         """,
#         ^"8711b2c57f28472ab1a542655d685a12"
#       )
#     )
#   end

#   defp get_node_id(id) when is_binary(id), do: id
#   defp get_node_id(id) when is_atom(id), do: Atom.to_string(id)
#   defp get_node_id(data = %{data: %{id: id}} = _unit), do: id

#   ######################################################################
#   # EXTEND PERMISSIONS ####################################################
#   ######################################################################

#   def add_permission_company(
#         %Arke.Core.Unit{} = user,
#         unit,
#         %ArkeAuth.Boundary.PermissionStruct{} = permission
#       ) do
#     unit_id = get_node_id(unit)

#     with {:ok, _} <- get_permitted_nodes(user, unit, :write) do
#       add_node(user.data.company, unit, permission)
#     else
#       {:error, msg} -> {:error, msg}
#     end
#   end

#   def add_permission_to_company(_, _, _), do: {:error, "invalid parameters"}

#   def add_permission_to_user(owner, unit, user) do
#     owner_id = get_node_id(owner)
#     unit_id = get_node_id(unit)
#     user_id = get_node_id(user)

#     permission =
#       ArkeAuth.Boundary.PermissionStruct.create_shared(%{read: true, shared_by: owner_id})

#     with {:ok, _} <- get_permitted_nodes(owner, unit, :write) do
#       add_node(user, unit, permission)
#     else
#       {:error, msg} -> {:error, msg}
#     end
#   end

#   defp create_and_add_permission(user, unit, data) do
#     with {:ok, created_unit} <- QueryManager.create(unit, data) do
#       permission =
#         ArkeAuth.Boundary.PermissionStruct.create(%{read: true, write: true, delete: true})

#       add_node(user, created_unit, permission)
#     else
#       err -> err
#     end
#   end

#   def revoke_permission(owner, unit, user) do
#     unit_id = get_node_id(unit)
#     user_id = get_node_id(user)

#     with true <- Enum.member?(get_shared_nodes(owner), unit_id),
#          {:ok, _} <- check_existing_node(user_id, unit_id) do
#       arke_auth = ArkeManager.get(:arke_auth, :arke_system)
#     else
#       err -> err
#     end
#   end

#   ######################################################################
#   # CLI PERMISSIONS ####################################################
#   ######################################################################

#   defp get_user_type(%Arke.Core.Unit{} = user), do: user.data.type
#   defp get_user_type(user), do: user.type

#   def create(user, unit, data) do
#     case to_string(get_user_type(user)) do
#       "super_admin" -> create_and_add_permission(user, unit, data)
#       "admin" -> create_and_add_permission(user, unit, data)
#       "customer" -> {:error, "user not authorized"}
#     end
#   end

#   def update(user, unit, data_to_update) do
#     with {:ok, _} <- get_permitted_nodes(user, unit, :write) do
#       QueryManager.update(unit, data_to_update)
#     else
#       {:error, msg} -> {:error, msg}
#     end
#   end

#   def delete(user, unit) do
#     with {:ok, _} <- get_permitted_nodes(user, unit, :delete) do
#       QueryManager.delete(unit)
#     else
#       {:error, msg} -> {:error, msg}
#     end
#   end
# end
