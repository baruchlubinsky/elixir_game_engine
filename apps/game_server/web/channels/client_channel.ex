defmodule GameServer.ClientChannel do
  use Phoenix.Channel

  def join("client:point", %{user_id: user_id}, socket) do
    {:ok, pid} = Point.new(user_id)
    Task.start_link(fn -> loop_send(socket, pid) end)
    {:ok, socket}
  end

  def handle_in("client:point", %{id: user_id, event: _name, value: _arg} = event, socket) do
    Character.send(String.to_atom(user_id), event)
  end

  def loop_send(socket, pid) do
      state = Character.get(pid)
      broadcast! socket, "new_state", %{sprites: [state]}
      :timer.sleep(5)
      loop_send(socket, pid)
  end
end