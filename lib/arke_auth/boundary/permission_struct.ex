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

# defmodule ArkeAuth.Boundary.PermissionStruct do
#   @moduledoc false
#   defstruct read: true, write: false, delete: false, shared_by: nil

#   def create(r, w, d) when is_boolean(r) and is_boolean(w) and is_boolean(d) do
#     %ArkeAuth.Boundary.PermissionStruct{read: r, write: w, delete: d}
#   end

#   def create(params) when is_list(params) do
#     with true <- Keyword.keyword?(params),
#          validate_values(params),
#          do: struct(%ArkeAuth.Boundary.PermissionStruct{}, params),
#          else:
#            (_ ->
#               {:error,
#                "invalid params. Use: #{Map.keys(%ArkeAuth.Boundary.PermissionStruct{}) |> List.delete(:__struct__)}"})
#   end

#   def create(params) when is_map(params) do
#     with true <- validate_values(params),
#          do: struct(%ArkeAuth.Boundary.PermissionStruct{}, params),
#          else: (_ -> {:error, "values must be boolean"})
#   end

#   def create(_), do: %ArkeAuth.Boundary.PermissionStruct{}

#   def create_shared(params) when is_list(params) do
#     with true <- Keyword.keyword?(params), Keyword.has_key?(params, :shared_by) do
#       owner_id = to_string(Keyword.get(params, :shared_by))
#       remove_owner = Keyword.delete(params, :shared_by)

#       with true <- validate_values(remove_owner),
#            do:
#              struct(%ArkeAuth.Boundary.PermissionStruct{}, remove_owner ++ [shared_by: owner_id]),
#            else: (_ -> {:error, "invalid parameters"})
#     end
#   end

#   def create_shared(params) when is_map(params) do
#     with true <- Map.has_key?(params, :shared_by) do
#       owner_id = to_string(params.shared_by)
#       remove_owner = Map.delete(params, :shared_by)

#       with true <- validate_values(remove_owner) do
#         struct(
#           %ArkeAuth.Boundary.PermissionStruct{},
#           Map.merge(remove_owner, %{shared_by: owner_id})
#         )
#       else
#         _ -> {:error, "invalid parameters"}
#       end
#     end
#   end

#   def create_shared(_), do: {:error, "invalid params"}

#   defp validate_values(params) do
#     Enum.all?(params, fn {k, v} -> is_boolean(v) end)
#   end
# end
