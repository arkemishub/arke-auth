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

defmodule ArkeAuth.Core.Otp do
  alias ArkeAuth.Core.Otp

  @moduledoc """
             Documentation for `Otp`.
             """ && false

  use Arke.System

  arke remote: true do
    parameter(:member_id, :string, label: "Member id", required: true)
    parameter(:code, :string, required: true)
    parameter(:action, :string, required: true)
    parameter(:expiry_datetime, :datetime, required: true)
  end
end
