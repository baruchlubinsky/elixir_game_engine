defmodule Character do
    def advance(pid, time) do
        GenServer.cast(pid, {:tick, time})
    end

    def get(pid) do
        GenServer.call(pid, {:get})
    end

    def send(pid, msg, reply_to \\ nil) do
        GenServer.cast(pid, {:do_interaction, reply_to, msg})
    end

    defmacro __using__(_args) do
        quote do 
            @behaviour :gen_server
            import GameEngine, only: [now: 0]
    
            def init(_args) do
                { :ok, [timestamp: now()] }
            end

            def export(state) do state end

            def interact(state, _msg) do state end

            def react(state, _msg) do state end

            def advance(state, timestamp) do 
                Keyword.put(state, :timestamp, timestamp)
            end

            def handle_call({:get, at}, from, state) do
                state = advance(state, at)
                {:reply, export(state), state}
            end

            def handle_call({:get}, from, state) do
                {:reply, export(state), state}
            end

            def handle_call(_request, _from, state) do
                { :noreply, state }
            end

            def handle_cast({:do_interaction, from, msg}, state) do
                parent = self
                spawn fn ->  
                    GenServer.cast(parent, {:reply_interaction, from, interact(state, msg)})
                end
                {:noreply, state}
            end

            def handle_cast({:reply_interaction, _from, msg}, state) do
                {:noreply, msg}
            end

            def handle_cast({:tick, at}, state) do
                {:noreply, advance(state, at)}
            end

            defoverridable [advance: 2, init: 1, interact: 2, react: 2, export: 1]

        end
    end
end
