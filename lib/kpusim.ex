defmodule Kpusim do
  require Logger

  @source_clk_count 3
  @sink_clk_count   1
  @pe_clk_count     1

  @doc """
  The init function will create a fabric of no_of_pes PEs, along with a Source and
  a Sink and tie them together in a pipeline. Each component in the fabric is
  a spawned process that primarily listens for clkin signals. Every component has
  an associated clk_count which is used to determine at which clock signal a component is
  supposed to execute, i.e., when the signal count mod clk_count equals zero.

  An initial value argument is used to prime the computation. It is the value that
  the Source process sends to the first PE process.

  A function argument is passed to every PE that is started. This is the function
  that a PE must execute/compute. The function takes one argument - the data that
  has been received by the PE.

  A clock is spawned as a separate process and given the fabric. The clocks
  responsibility is to signal every component in the fabric.

  Typical Usage:
    Kpusim.init(250, 6, 2, 4, fn x -> x * x end)

    Run the simulation with a step time of 250 milliseconds for 6 steps. Use an
    initial value of 2 and a pipeline of 4 PEs. Have each PE compute the square
    of the data token. No debugging text is displayed (the default).

  NOTE: Set the logging configuration to :debug in the config/config.exs file
  to see process messages during the simulation or pass it in to the init
  function below (the default is :info).

  """
  def init(step_time, number_of_steps, initial_data, no_of_pes, pe_fun, log_level \\ :info) do
    # Set the logging level to control the messages displayed on the console
    Logger.configure([level: log_level])
    # Start a source process with an initial data value
    source = spawn(Source, :init, [initial_data])
    sink = spawn(Sink, :init, [])
    # The fabric is initialized with the source and sink
    fabric = %{0 => {source, @source_clk_count},
               no_of_pes + 1 => {sink, @sink_clk_count}}
    # Finish building the fabric by starting the PEs
    fabric = Enum.reduce(1..no_of_pes, fabric, fn id, new_fabric ->
      Map.put_new(new_fabric, id, {spawn(PE, :init, [id, pe_fun]), 1})
    end)
    # Wire up the fabric as a pipeline
    send source, {:right, elem(Map.get(fabric, 1), 0)}
    Enum.each(1..no_of_pes, fn id ->
      left_pid = elem(Map.get(fabric, id - 1), 0)
      right_pid = elem(Map.get(fabric, id + 1), 0)
      pe_pid = elem(Map.get(fabric, id), 0)
      send pe_pid, {:left, left_pid, :right, right_pid}
    end)
    # Create a cpu clock that will signal every component in the fabric
    clock = spawn(Clock, :loop, [fabric])
    # Start a simulation loop that will trigger a clock signal every
    # step_time milliseconds and do this number_of_steps times.
    loop(clock, step_time, number_of_steps, 0)
  end

  @doc """
  loop controls the simulation by telling the clock to send a signal every
  step_time milliseconds a number_of_steps times.
  """
  def loop(clock, step_time, number_of_steps, running_count) do
    receive do
    after step_time ->
       if number_of_steps > 0 do
         send clock, {:step, running_count}
         loop(clock, step_time, number_of_steps - 1, running_count + 1)
       end
    end
  end

end
