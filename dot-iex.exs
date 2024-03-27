defmodule Aliases do
  def q, do: :init.stop()
  def r, do: recompile()
end

import Aliases

if Code.ensure_loaded?(Repo) do
  defmodule H do
    def update(schema, changes) do
      schema
      |> Ecto.Changeset.change(changes)
      |> Repo.update()
    end
  end
end

import_if_available(Ecto.Query)
import_if_available(Ecto.Changeset)

Application.put_env(:elixir, :ansi_enabled, true)

timestamp = fn ->
  {_date, {hour, minute, _second}} = :calendar.local_time()

  [hour, minute]
  |> Enum.map_join(":", &String.pad_leading(Integer.to_string(&1), 2, "0"))
end

IEx.configure(
  colors: [
    syntax_colors: [
      number: :light_yellow,
      atom: :light_cyan,
      string: :light_black,
      boolean: :red,
      nil: [:magenta, :bright]
    ],
    ls_directory: :cyan,
    ls_device: :yellow,
    doc_code: :green,
    doc_inline_code: :magenta,
    doc_headings: [:cyan, :underline],
    doc_title: [:cyan, :bright, :underline]
  ],
  default_prompt:
    "#{IO.ANSI.green()}%prefix#{IO.ANSI.reset()} " <>
      "[#{IO.ANSI.magenta()}#{timestamp.()}#{IO.ANSI.reset()} " <>
      ":: #{IO.ANSI.cyan()}%counter#{IO.ANSI.reset()}] >",
  alive_prompt:
    "#{IO.ANSI.green()}%prefix#{IO.ANSI.reset()} " <>
      "(#{IO.ANSI.yellow()}%node#{IO.ANSI.reset()}) " <>
      "[#{IO.ANSI.magenta()}#{timestamp.()}#{IO.ANSI.reset()} " <>
      ":: #{IO.ANSI.cyan()}%counter#{IO.ANSI.reset()}] >",
  history_size: -1,
  inspect: [
    pretty: true,
    limit: :infinity,
    width: 80,
    custom_options: [sort_maps: true]
  ],
  width: 80
)
