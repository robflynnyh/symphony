defmodule SymphonyElixir.Codex.IssueLabelOverrides do
  @moduledoc """
  Converts opt-in Linear labels into Codex turn-level runtime overrides.
  """

  alias SymphonyElixir.Linear.Issue

  @effort_values ~w(minimal low medium high xhigh)
  @model_prefix "codex:model:"
  @effort_prefix "codex:effort:"
  @thinking_prefix "codex:thinking:"
  @model_pattern ~r/^[a-z0-9][a-z0-9._-]*$/

  @spec turn_params(Issue.t() | map(), boolean()) :: map()
  def turn_params(_issue, false), do: %{}

  def turn_params(issue, true) do
    labels = issue_labels(issue)

    %{}
    |> maybe_put("model", model_from_labels(labels))
    |> maybe_put("effort", effort_from_labels(labels))
  end

  defp issue_labels(%Issue{labels: labels}), do: normalize_labels(labels)
  defp issue_labels(%{labels: labels}), do: normalize_labels(labels)
  defp issue_labels(_issue), do: []

  defp normalize_labels(labels) when is_list(labels) do
    labels
    |> Enum.filter(&is_binary/1)
    |> Enum.map(&String.downcase(String.trim(&1)))
    |> Enum.reject(&(&1 == ""))
  end

  defp normalize_labels(_labels), do: []

  defp model_from_labels(labels) do
    labels
    |> Enum.find_value(&label_value(&1, @model_prefix))
    |> validate_model()
  end

  defp effort_from_labels(labels) do
    labels
    |> Enum.find_value(fn label ->
      label_value(label, @effort_prefix) || label_value(label, @thinking_prefix)
    end)
    |> validate_effort()
  end

  defp label_value(label, prefix) do
    if String.starts_with?(label, prefix) do
      label
      |> String.replace_prefix(prefix, "")
      |> String.trim()
    end
  end

  defp validate_model(model) when is_binary(model) do
    if String.match?(model, @model_pattern), do: model
  end

  defp validate_model(_model), do: nil

  defp validate_effort(effort) when effort in @effort_values, do: effort
  defp validate_effort(_effort), do: nil

  defp maybe_put(params, _key, nil), do: params
  defp maybe_put(params, key, value), do: Map.put(params, key, value)
end
