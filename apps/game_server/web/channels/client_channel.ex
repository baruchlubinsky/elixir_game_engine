defmodule GameServer.ClientChannel do
  use Phoenix.Channel

  def join("viewport", %{"user_id" => user_id}, socket) do
    pid = GameEngine.add_character(GameEngine.Supervisor, Point, [[id: user_id]])
    Agent.update(GameServer.Characters, fn state -> Map.put(state, user_id, pid) end)
    {:ok, socket}
  end
  
  def handle_in("event", %{"user_id" => user_id, "event" => event}, socket) do
    character = Agent.get(GameServer.Characters, fn state -> Map.get(state, user_id, nil) end)
    Character.send(character, event)
    {:noreply, socket}
  end

end