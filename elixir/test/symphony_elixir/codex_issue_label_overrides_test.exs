defmodule SymphonyElixir.CodexIssueLabelOverridesTest do
  use SymphonyElixir.TestSupport

  alias SymphonyElixir.Codex.IssueLabelOverrides

  test "label overrides are opt in" do
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
end
