defmodule CuteFocusWeb.PageController do
  use CuteFocusWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
