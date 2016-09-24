defmodule GameServer do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(GameServer.Endpoint, []),
      
      worker(Agent, [fn -> %{} end, [name: GameServer.Characters]]),
      worker(Task, [fn -> game_loop() end])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GameServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    GameServer.Endpoint.config_change(changed, removed)
    :ok
  end

  def game_loop() do
    GameServer.Endpoint.broadcast "viewport", "new_state", GameEngine.render(GameEngine.Supervisor) 
    :timer.sleep(10)
    game_loop
  end
end
