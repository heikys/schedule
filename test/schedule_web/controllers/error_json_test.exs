defmodule ScheduleWeb.ErrorJSONTest do
  use ScheduleWeb.ConnCase, async: true

  test "renders 404" do
    assert ScheduleWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert ScheduleWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
