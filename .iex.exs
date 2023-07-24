defmodule Aliases do
  def q, do: :init.stop()
end

import Aliases

IEx.configure(
  inspect: [limit: :infinity],
  history_size: -1
)
