defmodule Play.Scene.PlayerDeath do
  @moduledoc """
  Render the player's death
  """

  use Scenic.Scene
  import Scenic.Primitives
  alias Scenic.Graph

  @initial_graph Graph.build()

  defmodule State do
    @moduledoc false
    defstruct [:size, :graph, :time]

    @type t :: %__MODULE__{}
  end

  def init({x, y}, opts) do
    Process.register(self(), __MODULE__)
    size = 3

    graph =
      @initial_graph
      |> circle(size, t: {x, y}, id: :circle, stroke: {3, :white}, fill: :white)
      |> push_graph()

    state = %{graph: graph, size: size, time: 0, viewport: opts[:viewport]}

    Process.send_after(self(), :animate, 10)

    {:ok, state}
  end

  def handle_info(:animate, %{time: t} = state) when t >= 150 do
    Scenic.ViewPort.set_root(state.viewport, {Play.Scene.Splash, Play.Scene.Asteroids})
    {:noreply, state}
  end

  def handle_info(:animate, state) do
    %{graph: graph, size: size} = state

    graph =
      graph
      |> Graph.modify(:circle, & circle(&1, size))
      |> push_graph()

    Process.send_after(self(), :animate, 10)
    state = %{state | graph: graph, size: size + 1, time: state.time + 1}

    {:noreply, state}
  end

  def handle_call(:reload_current_scene, _, _state), do: restart()

  defp restart, do: Process.exit(self(), :kill)
end
