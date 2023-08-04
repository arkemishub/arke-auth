defmodule ArkeAuth.Utils.SetupOAuth do
  alias Arke.Boundary.{GroupManager, ArkeManager, ParameterManager, ParamsManager}
  alias Arke.Core.Unit

  def setup(%{group: group} = _data) do
    oauth_id =
      Unit.new(
        :oauth_id,
        Map.merge(
          base_parameter(label: "Oauth id"),
          %{
            format: :attribute,
            is_primary: false,
            nullable: true,
            required: false,
            persistence: "arke_parameter",
            helper_text: nil,
            min_length: 2,
            max_length: nil,
            strip: false,
            values: nil,
            multiple: false,
            unique: false,
            default_string: nil
          }
        ),
        :string,
        nil,
        %{},
        nil,
        nil,
        nil
      )

    check_parameter([oauth_id])
    Enum.each(group, &check_group/1)

    :ok
  end

  defp base_parameter(opts \\ []) do
    %{
      label: Keyword.get(opts, :label),
      format: Keyword.get(opts, :format, :attribute),
      is_primary: Keyword.get(opts, :is_primary, false),
      nullable: Keyword.get(opts, :nullable, true),
      required: Keyword.get(opts, :required, false),
      persistence: Keyword.get(opts, :persistence, "arke_parameter"),
      helper_text: Keyword.get(opts, :label, nil)
    }
  end

  defp check_group(%{id: id, metadata: data} = _group) do
    label = Keyword.get(data, :label, String.capitalize(to_string(id)))
    description = Keyword.get(data, :description, String.capitalize(to_string(id)))

    case GroupManager.get(id, :arke_system) do
      %Unit{} = _unit ->
        nil

      _ ->
        GroupManager.create(
          Unit.new(
            id,
            %{
              label: label,
              description: description,
              arke_list: []
            },
            :group,
            nil,
            %{},
            nil,
            nil,
            nil
          ),
          :arke_system
        )
    end
  end

  defp check_parameter(parameter_list) do
    Enum.each(parameter_list, fn p ->
      with nil <- ParamsManager.get(p.id, :arke_system),
           {:error, _} <- ParameterManager.get(p.id, :arke_system) do
        ParamsManager.create(p, :arke_system)
        ParameterManager.create(p, :arke_system)
      else
        _ -> nil
      end
    end)
  end
end
