defmodule Sink do
  require Logger

  @doc """
  Start the process loop for this Sink component.
  """
  def init do
    loop
  end

  @doc """
  Listen for clock signals or data signals. On receiving a data token, simply
  display it in the log. The data value should typically be the final result of
  a computation.
  """
  def loop do
    receive do
      # Clock signal has arrived
      {:clkin, count} ->
        Logger.debug("Sink.clkin.#{count}")
        loop
      # A data token has arrived.
      {:data, data} ->
        Logger.info("Sink.data: #{data}")
        loop
    end
  end
end
