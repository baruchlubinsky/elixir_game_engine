defmodule GameEngine do
  use Application
  import Supervisor.Spec, warn: false

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do   

    # Define workers and child supervisors to be supervised
    children = [
      # Will eventually start the game world here.      
    ]

    opts = [strategy: :one_for_one, name: GameEngine.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def now() do
      :erlang.system_time(:nano_seconds) / 1_000_000_000
  end

  def add_character(engine, character, opts) do
    case Supervisor.start_child(engine, worker(character, opts)) do
      {:ok, child} -> child
      {:error, {:already_started, child} } -> child 
    end
  end 

  def render(engine) do
    %{"sprites" => for {_id, child, _type, _modules} <- Supervisor.which_children(engine) do
      Character.get(child)
    end,
    "timestamp" => now}
  end

end
