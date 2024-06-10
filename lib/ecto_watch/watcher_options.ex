defmodule EctoWatch.WatcherOptions do
  defstruct [:schema_mod, :update_type, :opts]

  def validate_list([]) do
    {:error, "requires at least one watcher"}
  end

  def validate_list(list) when is_list(list) do
    result =
      list
      |> Enum.map(&validate/1)
      |> Enum.find(&match?({:error, _}, &1))

    result || {:ok, list}
  end

  def validate_list(_) do
    {:error, "should be a list"}
  end

  def validate({schema_mod, update_type}) do
    validate({schema_mod, update_type, []})
  end

  def validate({schema_mod, update_type, opts}) do
    if EctoWatch.Helpers.is_ecto_schema_mod?(schema_mod) do
      if update_type in [:inserted, :updated, :deleted] do
        {:ok, {schema_mod, update_type}}
      else
        {:error,
         "Unexpected update_type to be one of :inserted, :updated, or :deleted. Got: #{inspect(update_type)}"}
      end
    else
      {:error, "Expected schema_mod to be an Ecto schema module. Got: #{inspect(schema_mod)}"}
    end
  end

  def validate(other) do
    {:error,
     "should be either `{schema_mod, update_type}` or `{schema_mod, update_type, opts}`.  Got: #{inspect(other)}"}
  end

  def new({schema_mod, update_type}) do
    new({schema_mod, update_type, []})
  end

  def new({schema_mod, update_type, opts}) do
    %__MODULE__{schema_mod: schema_mod, update_type: update_type, opts: opts}
  end
end
