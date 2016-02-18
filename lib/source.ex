defmodule Source do
  require Logger

  @doc """
  Initialize this Source component with a data value and start its process loop.
  """
  def init(data \\ 0) do
    loop(data, nil)
  end

  @doc """
  The Source components process loop. Listen for clock signals and when one
  arrives sends a data token to the PE process that the Source is attached to.

  A "wiring" message establishes which PE process to send data to. This must be
  established before simulation can be performed correctly.
  """
  def loop(data, right_pid) do
    receive do
      # The clock signal
      {:clkin, count} ->
        Logger.debug("Source.clkin.#{count} - with data #{data}")
        send right_pid, {:data, data}
        loop(data, right_pid)
      # Wiring message
      {:right, right_pid} ->
        loop(data, right_pid)
    end
  end
end
