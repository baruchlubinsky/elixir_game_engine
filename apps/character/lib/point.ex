defmodule Point do
    use Character

    defstruct x: 0.0, y: 0.0, dx: 0.0, dy: 0.0, ddx: 0.0, ddy: 0.0, m: 1.0

    def init(args) do
        this = self()
        Task.start_link(fn -> run_loop(this) end)
        {:ok, args}
    end

    def new(id) do
        GenServer.start(__MODULE__, [id: id, location: %Point{}, timestamp: now], name: String.to_atom(id))
    end

    def advance(state, timestamp) do
        dt = timestamp - Keyword.fetch!(state, :timestamp)
        if dt > 0 do
            {_, state} = Keyword.get_and_update!(state, :location, fn current ->
                {current, %Point{
                    x: current.x + current.dx * dt,
                    y: current.y + current.dy * dt,
                    dx: current.dx + current.ddx * dt,
                    dy: current.dy + current.ddy * dt,
                    ddx: current.ddx,
                    ddx: current.ddy,
                    m: current.m
                }}    
            end)
            {_, state} = Keyword.get_and_update!(state, :timestamp, fn t -> {t, timestamp} end)
            state
        else
            state
        end
    end

    def interact(state, [fx: fx, fy: fy]) do 
        {_, state} = Keyword.get_and_update(state, :location, fn current ->
               {_, new} = Map.get_and_update(current, :ddx, fn a -> {a, a + fx / current.m } end)
               {_, new} = Map.get_and_update(new, :ddy, fn a -> {a, a + fy / current.m } end)  
               {current, new}  
            end)
        state
    end

    def interact(state, %{event: "key" <> event, value: "Arrow" <> direction}) do
        speed = 0.1
        d = if event == "Up" do
            -1
        else
            1
        end
        f = case direction do
            "Up" -> [fx: 0, fy: d*speed]
            "Down" -> [fx: 0, fy: -d*speed]
            "Left" -> [fx: -d*speed, fy: 0]
            "Right" -> [fx: d*speed, fy: 0]
        end
        interact(state, f)
    end

    def run_loop(me) do 
        :ok = Character.advance(me, now)
        :timer.sleep(1000)
        run_loop(me)
    end
end