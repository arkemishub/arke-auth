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

defmodule ArkeAuth.Guardian do
  @moduledoc """
             Guardian callbacks
             """
  use Guardian, otp_app: :arke_auth

  @doc """
  The resource used to generate the tokens
  """
  def subject_for_token(member, _claims) do
    jwt_data = %{
      id: to_string(member.id),
      project: member.metadata.project
    }
    sub = Map.merge(jwt_data, member.data)
    {:ok, sub}
  end

  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end

  @doc """
  Get from the token the resource
  """
  def resource_from_claims(claims) do
    id = claims["sub"]["id"]
    project = String.to_existing_atom(claims["sub"]["project"])
    case Arke.QueryManager.get_by(project: project, group_id: "arke_auth_member", id: id) do
      nil -> {:error, :unauthorized}
      member ->
      data = Map.get(member,:data,%{})
      inactive = Map.get(data,:inactive,false)
      if inactive do
        {:error, :unauthorized}
        else
        {:ok, member}
      end

    end
  end

  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end
end
