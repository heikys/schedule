defmodule ScheduleWeb.PageController do
  use ScheduleWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
