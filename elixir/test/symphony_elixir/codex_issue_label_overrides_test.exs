defmodule SymphonyElixir.CodexIssueLabelOverridesTest do
  use SymphonyElixir.TestSupport

  alias SymphonyElixir.Codex.IssueLabelOverrides

  test "label overrides can be disabled" do
    issue = %Issue{labels: ["codex:model:gpt-5.5-pro", "codex:thinking:xhigh"]}

    assert IssueLabelOverrides.turn_params(issue, false) == %{}
  end

  test "extracts model and thinking labels for turn start params" do
    issue = %Issue{labels: ["infra", "codex:model:gpt-5.5-pro", "codex:thinking:xhigh"]}

    assert IssueLabelOverrides.turn_params(issue, true) == %{
             "model" => "gpt-5.5-pro",
             "effort" => "xhigh"
           }
  end

  test "accepts effort as a thinking label alias" do
    issue = %Issue{labels: ["codex:effort:high"]}

    assert IssueLabelOverrides.turn_params(issue, true) == %{"effort" => "high"}
  end

  test "accepts max and ultra thinking efforts" do
    assert IssueLabelOverrides.turn_params(%Issue{labels: ["codex:thinking:max"]}, true) == %{
             "effort" => "max"
           }

    assert IssueLabelOverrides.turn_params(%Issue{labels: ["thinking:ultra"]}, true) == %{
             "effort" => "ultra"
           }
  end

  test "extracts short Linear label forms" do
    issue = %Issue{labels: ["model:gpt-5.5", "thinking:low"]}

    assert IssueLabelOverrides.turn_params(issue, true) == %{
             "model" => "gpt-5.5",
             "effort" => "low"
           }
  end

  test "ignores invalid override labels" do
    issue = %Issue{labels: ["codex:model:gpt 5", "codex:effort:warp"]}

    assert IssueLabelOverrides.turn_params(issue, true) == %{}
  end

  test "extracts labels from map-shaped issues" do
    issue = %{labels: ["codex:model:gpt-5.5-pro", "effort:minimal"]}

    assert IssueLabelOverrides.turn_params(issue, true) == %{
             "model" => "gpt-5.5-pro",
             "effort" => "minimal"
           }
  end

  test "ignores missing and malformed labels" do
    assert IssueLabelOverrides.turn_params(%{labels: "codex:model:gpt-5.5-pro"}, true) == %{}
    assert IssueLabelOverrides.turn_params(%{}, true) == %{}
  end
end
